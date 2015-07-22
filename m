From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] af_mpls: fix undefined reference to
 ip6_route_output
Date: Wed, 22 Jul 2015 14:23:09 +0200
Message-ID: <20150722122309.GB968@pox.localdomain>
References: <1437549003-35563-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:37577 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964797AbbGVMXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 08:23:12 -0400
Received: by wibud3 with SMTP id ud3so169741251wib.0
        for <netdev@vger.kernel.org>; Wed, 22 Jul 2015 05:23:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1437549003-35563-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/15 at 12:10am, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> 
> seen with CONFIG_IPV6 disabled. Wrap the code
> around IS_ENABLED(CONFIG_IPV6)
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

We need the same for CONFIG_INET=n in inet_fib_lookup_dev:

/home/tgraf/dev/linux/net-next/include/net/route.h:122: undefined reference to `ip_route_output_flow'

Is it worth returning EAFNOSUPPORT instead of ENODEV in these
cases?  Something like this:

>  }
> +#else
> +static struct net_device *inet6_fib_lookup_dev(struct net *net, void *addr)
> +{
 +	return ERR_PTR(-EAFNOSUPPORT);
> +}
> +#endif

And then IS_ERR() in mpls_route_add()?
