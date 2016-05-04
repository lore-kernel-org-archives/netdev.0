From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] igmp: fix byte order in /proc/net/igmp output
Date: Wed, 04 May 2016 06:13:36 -0700
Message-ID: <1462367616.5535.340.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1462363884-34968-1-git-send-email-Eugene.Crosser@ru.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: crosser@average.org, netdev@vger.kernel.org
To: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35549 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750862AbcEDNNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 09:13:40 -0400
Received: by mail-pf0-f171.google.com with SMTP id 77so25185349pfv.2
        for <netdev@vger.kernel.org>; Wed, 04 May 2016 06:13:40 -0700 (PDT)
In-Reply-To: <1462363884-34968-1-git-send-email-Eugene.Crosser@ru.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-05-04 at 14:11 +0200, Eugene Crosser wrote:
> /proc/net/igmp is a readonly attribute that shows multicast groups
> to which different network interfaces are subscribed. Among other
> things, it displays `multiaddr` which is a 32 bit network-byte-order
> field, in hexadecimal format. Prior to this patch, the field was
> displayed as an integer, resulting in reverse byte order on little
> endian architectures. This patch converts it with ntohl() for display
> the same way as this is done for the /proc/net/mcfilter attribute.
> 
> The patch changes (corrects) user-visible behaviour.
> 
> Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
> ---
>  net/ipv4/igmp.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
> index b3086cf..f9d2139 100644
> --- a/net/ipv4/igmp.c
> +++ b/net/ipv4/igmp.c
> @@ -2722,7 +2722,7 @@ static int igmp_mc_seq_show(struct seq_file *seq, void *v)
>  		delta = im->timer.expires - jiffies;
>  		seq_printf(seq,
>  			   "\t\t\t\t%08X %5d %d:%08lX\t\t%d\n",
> -			   im->multiaddr, im->users,
> +			   ntohl(im->multiaddr), im->users,
>  			   im->tm_running,
>  			   im->tm_running ? jiffies_delta_to_clock_t(delta) : 0,
>  			   im->reporter);


I do not believe we can change this. This is unfortunately too late.

/proc/net/tcp has the same 'issue' or if you prefer, well known
behavior.

Such change would break basically all /proc/net/igmp users.
