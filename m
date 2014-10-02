From: "Stam, Michel [FINT]" <M.Stam@fugro.nl>
Subject: RE: ASIX 88772
Date: Thu, 2 Oct 2014 09:50:56 +0200
Message-ID: <C89EFD3CD56F64468D3D206D683A8D2203864153@ldam-msx2.fugro-nl.local>
References: <C89EFD3CD56F64468D3D206D683A8D2203863DD8@ldam-msx2.fugro-nl.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Stam, Michel [FINT]" <M.Stam@fugro.nl>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu1.fugro.com ([46.34.88.151]:40911 "EHLO
	smtp.eu1.fugro.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962AbaJBHu7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 03:50:59 -0400
Content-class: urn:content-classes:message
In-Reply-To: <C89EFD3CD56F64468D3D206D683A8D2203863DD8@ldam-msx2.fugro-nl.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LS,

Is it possible for someone to apply this patch?

Best regards,

Michel Stam

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Stam, Michel [FINT]
Sent: Monday, September 29, 2014 15:46 PM
To: netdev@vger.kernel.org
Subject: ASIX 88772

Dear list,

A while back we did an upgrade of the firmware running on our embedded
devices. These devices, amongst others, use an ASIX chip, model 88772A.

What we noticed, was that ethtool settings would be negated when the
interface was set to 'up'. This, effectively voided any control we tried
to exercise over the autonegotiation process (it always returns back to
100 Mbps/Full duplex). After comparing with the kernel we used before
(we used 2.6.22 before, now 3.10.34), I discovered that the difference
was the .link_reset function pointer defined in the driver_info struct
in drivers/net/usb/asix_devices.c:888. By setting it back to its
previous value, ax88772_link_reset, the functionality is restored and
ethtool behaves as expected.

Apparently this change to drivers/net/usb/asix_devices.c happened at
line 888 as part of commit 2e55cc721, which moved the driver into its
own file with that commit. It apparently also addresses some link reset
problems.

Would anyone have any idea what kind of link reset problems these were?

I have attached a git format-patch which works for us, but I would like
to make sure it does not break other devices instead. I've attached it
to this email because the mail client seems to corrupt the patches
occasionally.

Best regards,

Michel Stam
