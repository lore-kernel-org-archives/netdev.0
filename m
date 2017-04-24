From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH v2 net-next] net: ipv6: send unsolicited NA if enabled
 for all interfaces
Date: Mon, 24 Apr 2017 11:42:57 +0200
Message-ID: <20170424094255.GA32716@vergenet.net>
References: <1492877413-21906-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:38903 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1168111AbdDXJnA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 05:43:00 -0400
Received: by mail-wm0-f41.google.com with SMTP id r190so62117766wme.1
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 02:42:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1492877413-21906-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 22, 2017 at 09:10:13AM -0700, David Ahern wrote:
> When arp_notify is set to 1 for either a specific interface or for 'all'
> interfaces, gratuitous arp requests are sent. Since ndisc_notify is the
> ipv6 equivalent to arp_notify, it should follow the same semantics.
> Commit 4a6e3c5def13 ("net: ipv6: send unsolicited NA on admin up") sends
> the NA on admin up. The final piece is checking devconf_all->ndisc_notify
> in addition to the per device setting. Add it.
> 
> Fixes: 5cb04436eef6 ("ipv6: add knob to send unsolicited ND on link-layer address change")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Reviewed-by: Simon Horman <simon.horman@netronome.com>

> ---
> v2
> - update commit message with subject of commit 4a6e3c5def13 per comment
>   from Sergei
> 
>  net/ipv6/ndisc.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index b23822e64228..d310dc41209a 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -1753,7 +1753,8 @@ static int ndisc_netdev_event(struct notifier_block *this, unsigned long event,
>  		idev = in6_dev_get(dev);
>  		if (!idev)
>  			break;
> -		if (idev->cnf.ndisc_notify)
> +		if (idev->cnf.ndisc_notify ||
> +		    net->ipv6.devconf_all->ndisc_notify)
>  			ndisc_send_unsol_na(dev);
>  		in6_dev_put(idev);
>  		break;
> -- 
> 2.1.4
> 
