From: Peter Wu <lekensteyn@gmail.com>
Subject: [r8169] About the "PHY reset until link up" warning
Date: Mon, 22 Jul 2013 12:42:50 +0200
Message-ID: <2215813.0syAhGCZsc@al>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f43.google.com ([209.85.214.43]:50811 "EHLO
	mail-bk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757174Ab3GVKmy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 06:42:54 -0400
Received: by mail-bk0-f43.google.com with SMTP id jm2so2421775bkc.2
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 03:42:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

When a cable is not connected while an interface goes up, the "PHY rese=
t until=20
link up" warning is logged. Looking back in the history, this warning w=
as=20
added in:

commit a7154cb8326c6015b6c5d9ce482d2a1f4c268d99
Author: Fran=E7ois Romieu <romieu@fr.zoreil.com>
Date:   Wed Jun 2 12:03:02 2004 -0400

    [PATCH] r8169: link handling and phy reset rework
   =20
    Link handling changes (Andy Lutomirski <luto@myrealbox.com>):
    - removed rtl8169_hw_phy_reset() and its busy loop;
    - RTL8169_PHY_TIMEOUT is x10 to account for the removal of the
      phy_link_down_cnt loop in rtl8169_phy_timer();
    - added spinlocking in timer context for rtl8169_phy_timer to avoid
      messing with the {set/get}_settings commands issued via ethtool;
    - more TBI stuff.
   =20
    This patch differs from the former version on the following points:
    - the LinkChg irq does not enable the phy timer when the link goes
      down any more;
    - the phy timer is not enabled in rtl8169_set_speed();
    - removal of the initial renegotiation hack.
(via git://git.kernel.org/pub/scm/linux/kernel/git/tglx/history.git)

If this is a (hardware) bug workaround, can't it be restricted to that =
specific=20
hardware or removed altogether (perhaps firmware / other updates fixed =
it=20
already?). Otherwise, what about removing this debug message?

Manually running "ip link set eth1 down" brings the interface down and =
no=20
resets are being attempted. Another way to stop resetting the interface=
 is=20
inserting a cable, wait for link up and remove it again. This presumabl=
y works=20
because rtl8169_down() removes the reset timer.

Regards,
Peter
