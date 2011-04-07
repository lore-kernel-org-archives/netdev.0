From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Thu, 07 Apr 2011 18:03:38 +0200
Message-ID: <1302192218.3357.47.camel@edumazet-laptop>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wei Gu <wei.gu@ericsson.com>, netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54563 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019Ab1DGQDn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 12:03:43 -0400
Received: by wwa36 with SMTP id 36so3219429wwa.1
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2011 09:03:41 -0700 (PDT)
In-Reply-To: <4D9DDF43.9080302@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 07 avril 2011 =C3=A0 08:58 -0700, Alexander Duyck a =C3=A9crit=
 :
> On 4/7/2011 4:46 AM, Eric Dumazet wrote:
> > Le jeudi 07 avril 2011 =C3=A0 19:15 +0800, Wei Gu a =C3=A9crit :
> >> Hi,
> >> I compile the ixgbe driver into the kernel and run the test again =
and also change the copy to clone in the fw hook
> >> This is the perf report while I was forwarding 150Kpps with
> >> The attached file include the basic info about my test system. Ple=
ase let me know if I did some thing wrong.
> >>
> >> +     71.91%          swapper  [kernel.kallsyms]            [k] po=
ll_idle
> >> +     10.43%          swapper  [kernel.kallsyms]            [k] in=
tel_idle
> >> -      8.00%     ksoftirqd/24  [kernel.kallsyms]            [k] _r=
aw_spin_unlock_irqrestore
> >> \u2592   - _raw_spin_unlock_irqrestore
> >> \u2592      - 42.25% alloc_iova
> >> \u2592           intel_alloc_iova
> >> \u2592           __intel_map_single
> >> \u2592           intel_map_page
>=20
> I'm almost certain this is the issue here.  I am pretty sure the=20
> intel_map_page call indicates that you are running with the Intel IOM=
MU=20
> enabled.  As Eric suggested you can either rebuild your kernel with=20
> "CONFIG_DMAR=3DN", or pass the kernel the parameter "intel_iommu=3Dof=
f" in=20
> order to disable it so that it will instead just use SWIOTLB.

What's the purpose of intel_iommu ?

Could this be speedup if ixgbe uses a perqueue iommu context instead of
a per device, so that we dont hit a single spinlock ?


