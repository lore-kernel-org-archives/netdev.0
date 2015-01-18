From: Marcel Holtmann <marcel@holtmann.org>
Subject: Bridge code in net-next does not compile
Date: Sun, 18 Jan 2015 02:33:24 -0800
Message-ID: <D49DF51C-D713-4D2C-9CB0-F7C21403F68A@holtmann.org>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:43758 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341AbbARKd3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 05:33:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

when compiling net-next, the bridge code fails to compile:

  CC      net/bridge/br.o
In file included from net/bridge/br.c:22:0:
include/net/switchdev.h:73:1: error: expected identifier or =E2=80=98(=E2=
=80=99 before =E2=80=98{=E2=80=99 token
 {
 ^
include/net/switchdev.h:71:90: warning: =E2=80=98call_netdev_switch_not=
ifiers=E2=80=99 declared =E2=80=98static=E2=80=99 but never defined [-W=
unused-function]
 static inline int call_netdev_switch_notifiers(unsigned long val, stru=
ct net_device *dev,
                                                                       =
                   ^

I bisecting this to this commit:

commit 03bf0c281234028388108d0aee720954f5fe6924
Author: Jiri Pirko <jiri@resnulli.us>
Date:   Thu Jan 15 23:49:36 2015 +0100

    switchdev: introduce switchdev notifier
   =20
    This patch introduces new notifier for purposes of exposing events =
which happen
    on switch driver side. The consumers of the event messages are main=
ly involved
    masters, namely bridge and ovs.
   =20
    Suggested-by: Thomas Graf <tgraf@suug.ch>
    Signed-off-by: Jiri Pirko <jiri@resnulli.us>
    Signed-off-by: Scott Feldman <sfeldma@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Regards

Marcel
