From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next 0/2] Pack struct xfrm_usersa_info and struct
 xfrm_userpolicy_info
Date: Tue, 7 Jan 2014 08:47:24 +0100
Message-ID: <20140107074724.GV31491@secunet.com>
References: <1389077339-12814-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, stephen@networkplumber.org,
	dev@lists.strongswan.org, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60541 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754997AbaAGHr1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 02:47:27 -0500
Content-Disposition: inline
In-Reply-To: <1389077339-12814-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 07, 2014 at 02:48:57PM +0800, Fan Du wrote:
> When trying to setup IPsec configuration on a 64bits host with
> iproute2(32bits compiled), the intened xfrm policy and sa is
> either deficit or wrong when kernel trying to parse user land
> information.
> 
> Further investigatino shows that:
> L: kernel
> R: iproute2
> 
>           sizeof       userpolicy      usersa
> 64bits(unpacked)        168/168        224/224
> 32bits(unpacked)        164/164        220/220
>                          ^   ^
>                          L   R
> 
> To keep kernel and user land see a consistent structure, after
> add packing attribute, now it looks like this:
> 
> 64bits(  packed)        164/164        217/217
> 32bits(  packed)        164/164        217/217
>                          ^   ^
>                          L   R
> 

We don't change userspace exported structures. This breaks
existing userspace tools.
