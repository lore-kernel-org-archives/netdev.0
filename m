From: Wei Gu <wei.gu@ericsson.com>
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Fri, 8 Apr 2011 17:59:46 +0800
Message-ID: <D12839161ADD3A4B8DA63D1A134D084026E48BA5F7@ESGSCCMS0001.eapac.ericsson.se>
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
	 <1302192218.3357.47.camel@edumazet-laptop> <4D9DE465.1080008@intel.com>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA58D@ESGSCCMS0001.eapac.ericsson.se>
	 <1302253651.4409.2.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA5A9@ESGSCCMS0001.eapac.ericsson.se>
 <1302256158.4409.6.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:57972 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568Ab1DHKCS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2011 06:02:18 -0400
In-Reply-To: <1302256158.4409.6.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yeap, I guess the red hat guy make this config, since I chosed a no vir=
tualization setup of the RHEL6.

If the from 2.6.29 the DMAR_DEFAULT_ON is set, then I guess there will =
a big performance degrade at least for the Intel 10GE NIC.

I don't know if this kind of performance degrade is a fault Or it just =
meet the design expectation?

@Alexander, I guess you know much about this?

Thanks
WeiGu

-----Original Message-----
=46rom: Eric Dumazet [mailto:eric.dumazet@gmail.com]
Sent: Friday, April 08, 2011 5:49 PM
To: Wei Gu
Cc: Alexander Duyck; netdev; Kirsher, Jeffrey T
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel

Le vendredi 08 avril 2011 =E0 17:15 +0800, Wei Gu a =E9crit :
> Yeap, you are right, right now I will try the CONFIG_DMAR off:)
>
> If you guys know the relation between CONFIG_DMAR and
> CONFIG_DMAR_DEFAULT_ON, please let me know:)


CONFIG_DMAR_DEFAULT_ON is ON by default since linux-2.6.29 and commit

commit f6be37fdc62d0c0214bc49815d1180ebfbd716e2
Author: Kyle McMartin <kyle@redhat.com>
Date:   Thu Feb 26 12:57:56 2009 -0500

    x86: enable DMAR by default

    Now that the obvious bugs have been worked out, specifically
    the iwlagn issue, and the write buffer errata, DMAR should be safe
    to turn back on by default. (We've had it on since those patches we=
re
    first written a few weeks ago, without any noticeable bug reports
    (most have been due to the dma-api debug patchset.))

    Signed-off-by: Kyle McMartin <kyle@redhat.com>
    Acked-by: David Woodhouse <David.Woodhouse@intel.com>
    Signed-off-by: Ingo Molnar <mingo@elte.hu>

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig index 9c39095..bc2fbad=
 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -1803,7 +1803,7 @@ config DMAR
          remapping devices.

 config DMAR_DEFAULT_ON
-       def_bool n
+       def_bool y
        prompt "Enable DMA Remapping Devices by default"
        depends on DMAR
        help


git describe --contains f6be37fd
v2.6.29-rc7~24^2


But the .config used to build your 2.6.32 kernel, had it set to OFF



