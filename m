From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net] r8169: enforce RX_MULTI_EN on rtl8168ep/8111ep chips
Date: Tue, 4 Aug 2015 22:59:10 +0200
Message-ID: <20150804205910.GA31725@electric-eye.fr.zoreil.com>
References: <1438719103-22067-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, alexander@bitspace.se, nic_swsd@realtek.com
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40595 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932381AbbHDU7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 16:59:50 -0400
Content-Disposition: inline
In-Reply-To: <1438719103-22067-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ivan Vecera <ivecera@redhat.com> :
> Enforcing this flag in RxConfig for the mentioned chips fixes netdev
> watchdog issues prepended with AMD IOMMU message(s) like:
> AMD-Vi: Event logged [IO_PAGE_FAULT device=3D01:00.0 domain=3D0x001d =
address=3D0x0000000000003000 flags=3D0x0050]

=46WIW:
Acked-by: Francois Romieu <romieu@fr.zoreil.com>

Adding a #bz reference would be pointless:

commit 7a9810e7bd99c922d9cedf64dbaa5ef6be412295
Author: Michel D=C3=A4nzer <michel@daenzer.net>
Date:   Thu Jul 17 12:55:40 2014 +0900

    r8169: Enable RX_MULTI_EN for RTL_GIGA_MAC_VER_40
   =20
    The ethernet port on my ASUS A88X Pro mainboard stopped working
    several times a day, with messages like these in dmesg:
   =20
    AMD-Vi: Event logged [IO_PAGE_FAULT device=3D05:00.0 domain=3D0x001=
e address=3D0x0
000000000003000 flags=3D0x0050]
[...]
commit 3ced8c955e74d319f3e3997f7169c79d524dfd06
Author: fran=C3=A7ois romieu <romieu@fr.zoreil.com>
Date:   Sun Sep 8 01:15:35 2013 +0200

    r8169: enforce RX_MULTI_EN for the 8168f.
   =20
    Same narrative as eb2dc35d99028b698cdedba4f5522bc43e576bd2 ("r8169:=
 RxConfig
    hack for the 8168evl.") regarding AMD IOMMU errors.
   =20
    RTL_GIGA_MAC_VER_36 - 8168f as well - has not been reported to beha=
ve the
    same.
[...]
commit eb2dc35d99028b698cdedba4f5522bc43e576bd2
Author: fran=C3=A7ois romieu <romieu@fr.zoreil.com>
Date:   Wed Jun 20 12:09:18 2012 +0000

    r8169: RxConfig hack for the 8168evl.
   =20
    The 8168evl (RTL_GIGA_MAC_VER_34) based Gigabyte GA-990FXA motherbo=
ards
    are very prone to NETDEV watchdog problems without this change. See
    https://bugzilla.kernel.org/show_bug.cgi?id=3D42899 for instance.


--=20
Ueimor
