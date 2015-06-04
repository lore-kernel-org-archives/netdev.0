From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: double default TSQ output bytes limit
Date: Wed, 03 Jun 2015 23:51:54 -0700
Message-ID: <1433400714.1895.36.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1433326242-4061-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	George Dunlap <george.dunlap@eu.citrix.com>,
	David Miller <davem@davemloft.net>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:32918 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751685AbbFDGv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 02:51:56 -0400
Received: by igbpi8 with SMTP id pi8so8762917igb.0
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2015 23:51:55 -0700 (PDT)
In-Reply-To: <1433326242-4061-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-06-03 at 11:10 +0100, Wei Liu wrote:
> Xen virtual network driver has higher latency than a physical NIC.
> Having only 128K as limit for TSQ introduced 30% regression in guest
> throughput.
> 
> This patch raises the limit to 256K. This reduces the regression to 8%.
> This buys us more time to work out a proper solution in the long run.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> Cc: David Miller <davem@davemloft.net>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/ipv4/tcp_output.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 190538a..eeb59be 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -50,8 +50,8 @@ int sysctl_tcp_retrans_collapse __read_mostly = 1;
>   */
>  int sysctl_tcp_workaround_signed_windows __read_mostly = 0;
>  
> -/* Default TSQ limit of two TSO segments */
> -int sysctl_tcp_limit_output_bytes __read_mostly = 131072;
> +/* Default TSQ limit of four TSO segments */
> +int sysctl_tcp_limit_output_bytes __read_mostly = 262144;
>  
>  /* This limits the percentage of the congestion window which we
>   * will allow a single TSO frame to consume.  Building TSO frames

Acked-by: Eric Dumazet <edumazet@google.com>
