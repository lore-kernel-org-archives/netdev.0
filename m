From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] unix: show socket peer if no addr is given in /proc/net/unix
Date: Thu, 09 Jan 2014 01:19:06 +0300
Message-ID: <52CDCEDA.2080609@cogentembedded.com>
References: <1389158288-2855-1-git-send-email-yamato@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Masatake YAMATO <yamato@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f52.google.com ([209.85.215.52]:57892 "EHLO
	mail-la0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757472AbaAHVTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 16:19:03 -0500
Received: by mail-la0-f52.google.com with SMTP id y1so1570465lam.39
        for <netdev@vger.kernel.org>; Wed, 08 Jan 2014 13:19:01 -0800 (PST)
In-Reply-To: <1389158288-2855-1-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/08/2014 08:18 AM, Masatake YAMATO wrote:

> Path field of /proc/net/unix is empty if an address is not given
> to a socket. Typical way to create such socket is calling
> socketpair. The empty fields make it difficult to understand the
> communication between processes. e.g. lsof cannot resolve the role of
> file descriptors well.

> This patch fills the empty fields with unix_peer.

> Signed-off-by: Masatake YAMATO <yamato@redhat.com>
> ---
>   net/unix/af_unix.c | 5 ++++-
>   1 file changed, 4 insertions(+), 1 deletion(-)

> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 800ca61..1700133 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -2340,7 +2340,9 @@ static int unix_seq_show(struct seq_file *seq, void *v)
>   	else {
>   		struct sock *s = v;
>   		struct unix_sock *u = unix_sk(s);
> +		struct sock *s_peer;
>   		unix_state_lock(s);
> +		s_peer = unix_peer(s);
>
>   		seq_printf(seq, "%pK: %08X %08X %08X %04X %02X %5lu",
>   			s,
> @@ -2367,7 +2369,8 @@ static int unix_seq_show(struct seq_file *seq, void *v)
>   			}
>   			for ( ; i < len; i++)
>   				seq_putc(seq, u->addr->name->sun_path[i]);
> -		}
> +		} else if (s_peer)
> +			seq_printf(seq, " #%pK", s_peer);

    According to Documentation/CodingStyle, both arms of the *if* statement 
should have {} if one has it.

WBR, Sergei
