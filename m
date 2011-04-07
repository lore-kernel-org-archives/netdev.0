From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Thu, 07 Apr 2011 18:37:07 +0200
Message-ID: <1302194227.3357.52.camel@edumazet-laptop>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
	 <1302152327.2701.50.camel@edumazet-laptop>
	 <1302153412.2701.64.camel@edumazet-laptop>
	 <1302157012.2701.73.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9E82@ESGSCCMS0001.eapac.ericsson.se>
	 <1302163650.3357.8.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9F23@ESGSCCMS0001.eapac.ericsson.se>
	 <1302167168.3357.12.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA027@ESGSCCMS0001.eapac.ericsson.se>
	 <1302176811.3357.15.camel@edumazet-laptop>  <4D9DDF43.9080302@intel.com>
	 <1302192218.3357.47.camel@edumazet-laptop>  <4D9DE465.1080008@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wei Gu <wei.gu@ericsson.com>, netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49166 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754355Ab1DGQhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 12:37:11 -0400
Received: by wwa36 with SMTP id 36so3254062wwa.1
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2011 09:37:10 -0700 (PDT)
In-Reply-To: <4D9DE465.1080008@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 07 avril 2011 =C3=A0 09:20 -0700, Alexander Duyck a =C3=A9crit=
 :

> The intel_iommu is meant to be a security feature.  Primarily it is u=
sed=20
> in virtualzation where it allows KVM or Xen to direct assign a device=
=20
> without having to worry about the guest getting access to the hosts=20
> physical memory by submitting invalid DMA requests.
>=20

I see

> If virtualzation isn't in use I would recommend turning it off as it =
can=20
> have a negative impact especially on small packet performance due to =
the=20
> extra locking overhead that is required for DMA map and unmap calls.

Sure, but then, if this thing is ON, we should copy small packets in
freshly allocated skbs and reuse old one in driver rx handler, to avoid
the expensive dma calls ?

[ The thing called copybreak ]

I understand tx path cost cannot be avoided, so it would not help Wei
use case.

Thanks !


