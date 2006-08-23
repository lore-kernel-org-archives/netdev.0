From: James Morris <jmorris@namei.org>
Subject: Re: [RFC][PATCH 1/3] net/ipv4: UDP-Lite extensions
Date: Wed, 23 Aug 2006 10:22:24 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0608231019010.3198@d.namei>
References: <200608231150.42039@strip-the-willow>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, alan@lxorguk.ukuu.org.uk,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, kaber@coreworks.de,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:48265 "EHLO
	mail3.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S964900AbWHWOW0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 10:22:26 -0400
To: gerrit@erg.abdn.ac.uk
In-Reply-To: <200608231150.42039@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 23 Aug 2006, gerrit@erg.abdn.ac.uk wrote:

> +void __init udplite4_register(void)
> +{
> +	if (proto_register(&udplite_prot, 1))
> +		goto out_register_err;
> +
> +	if (inet_add_protocol(&udplite_protocol, IPPROTO_UDPLITE) < 0)
> +		goto out_unregister_proto;
> +
> +	inet_register_protosw(&udplite4_protosw);
> +
> +	return;
> +
> +out_unregister_proto:
> +	proto_unregister(&udplite_prot);
> +out_register_err:
> +	printk(KERN_ERR "udplite4_register: Cannot add UDP-Lite protocol\n");
> +}

Other protocols & network components call panic() if they fail during boot 
initialization.  Not sure if this is a great thing, but it raises the 
issue of whether udp-lite should remain consistent here.



- James
-- 
James Morris
<jmorris@namei.org>
