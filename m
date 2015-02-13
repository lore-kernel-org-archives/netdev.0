From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 3/3] ipv4: Create probe timer for tcp PMTU as
 per RFC4821
Date: Fri, 13 Feb 2015 04:31:49 -0800
Message-ID: <1423830709.4942.17.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1423815405-32644-1-git-send-email-fan.du@intel.com>
	 <1423815405-32644-4-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	fengyuleidian0615@gmail.com
To: Fan Du <fan.du@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:46665 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752520AbbBMMbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 07:31:52 -0500
Received: by mail-qc0-f180.google.com with SMTP id s11so13467325qcv.11
        for <netdev@vger.kernel.org>; Fri, 13 Feb 2015 04:31:51 -0800 (PST)
In-Reply-To: <1423815405-32644-4-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-02-13 at 16:16 +0800, Fan Du wrote:
> As per RFC4821 7.3.  Selecting Probe Size, a probe timer should
> be armed once probing has converged. Once this timer expired,
> probing again to take advantage of any path PMTU change. The
> recommended probing interval is 10 minutes per RFC1981.
> 
> Signed-off-by: Fan Du <fan.du@intel.com>
> ---
>  include/net/inet_connection_sock.h |    2 ++
>  include/net/netns/ipv4.h           |    1 +
>  include/net/tcp.h                  |    3 +++
>  net/ipv4/sysctl_net_ipv4.c         |    7 +++++++
>  net/ipv4/tcp.c                     |    2 ++
>  net/ipv4/tcp_ipv4.c                |    1 +
>  net/ipv4/tcp_output.c              |   23 ++++++++++++++++++++++-
>  7 files changed, 38 insertions(+), 1 deletions(-)
> 
> diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
> index 3d0932e..e78e5ab 100644
> --- a/include/net/inet_connection_sock.h
> +++ b/include/net/inet_connection_sock.h
> @@ -126,6 +126,8 @@ struct inet_connection_sock {
>  
>  		int		  search_high_sav;
>  		int		  search_low_sav;
> +
> +		struct timer_list probe_timer;
>  

We certainly wont add yet another timer in tcp socket for such usage.

And a buggy one, since you forgot all the refcounting associated with
such timers.
