From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [tcpdump-workers] vlan tagged packets and libpcap breakage
Date: Mon, 17 Dec 2012 09:50:17 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B70EF@saturn3.aculab.com>
References: <CAOxq_8Nd8VP3MaNBfUt9v82nmGDpxZz5_5QMdsruET1tjwuQPw@mail.gmail.com><3246.1351717319@obiwan.sandelman.ca><CAOxq_8PsXb-oUy85Eji7GSAbUZD_Bds8skmGNP4BWSewQWx8PA@mail.gmail.com><21992.1351723328@obiwan.sandelman.ca><alpine.OSX.2.00.1212121205040.78903@animac.local><50C9936B.2000201@redhat.com><CAOxq_8PuMF2n80g30aXbPFQyo6UfsypZOHREjB36dnnp87nv=A@mail.gmail.com> <CAD6jFUTht82HOjGjDU7hFCEWyE3TOx_W4_j=SZK-DrcGfrio-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Michael Richardson" <mcr@sandelman.ca>, <netdev@vger.kernel.org>,
	<tcpdump-workers@lists.tcpdump.org>,
	"Francesco Ruggeri" <fruggeri@aristanetworks.com>
To: "Daniel Borkmann" <danborkmann@iogearbox.net>,
	"Ani Sinha" <ani@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:38314 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750797Ab2LQJ54 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 04:57:56 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 15211-10 for <netdev@vger.kernel.org>;
 Mon, 17 Dec 2012 09:57:53 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <CAD6jFUTht82HOjGjDU7hFCEWyE3TOx_W4_j=SZK-DrcGfrio-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I do agree that instead of a /proc entry, we should check for a kenrel
> > version >= X where X is the upstream version that first started
> > supporting all the features needed by libpcap for vlan filtering. This
> > is not a compile time check but a run time one. Does anyone see any
> > issues with this? Is there any long term implications of this, like if
> > you backport patches to an older long term supported kernel? Are there
> > other better ways to do this, like may be returning feature bits from
> > an ioctl call? This is something we need to deal with on a continuous
> > basis as we keep supporting newer AUX fields and libpcap and other
> > user land code needs to make use of it. At the same time, they need to
> > handle backward compatibility issues with older kernels.
> 
> As Eric mentioned earlier, for now there seems not to be a reliable
> way to get to know which ops are present and which not. It's not
> really nice, but if you want to make use of those new (ANC*) features,
> probably checking kernel version might be the only way if I'm not
> missing something. Now net-next is closed, but if it reopens, I'll
> submit a version 2 of my patch where you've been CC'd to. If it gets
> in, then at least it's for sure that since kernel <xyz> this kind of
> feature test is present.

How are you going to tell whether a feature is present in a non-Linux
kernel ?

Testing kernel versions is somewhat suboptimal as support
could be patched into a much older kernel (maybe not for
this but ...)

	David
