From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 1/6] NetLabel: correctly initialize the NetLabel fields
Date: Tue, 29 Aug 2006 12:51:14 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0608291248410.29142@d.namei>
References: <20060829144251.452774000@hp.com> <20060829144444.202106000@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail6.sea5.speakeasy.net ([69.17.117.8]:47488 "EHLO
	mail6.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S965119AbWH2QvS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 12:51:18 -0400
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <20060829144444.202106000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 29 Aug 2006, paul.moore@hp.com wrote:

> +void selinux_netlbl_sk_security_init(struct sk_security_struct *ssec,
> +				     int family)
> +{
> +        if (family == PF_INET)

No tab.

> +		ssec->nlbl_state = NLBL_REQUIRE;
> +	else
> +		ssec->nlbl_state = NLBL_UNSET;
> +}

It doesn't look like this code handles ipv4 packets mapped on ipv6 
sockets.  See the test elsewhere in the SELinux code:

	if (family == PF_INET6 && skb->protocol == ntohs(ETH_P_IP))


Also, can you verify that you've tested these fixes and that they resolve 
all issues that you've encountered?



-- 
James Morris
<jmorris@namei.org>
