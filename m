From: ohashi-h@mb.dnes.nec.co.jp
Subject: =?utf-8?B?UmU6IGUxMDAwOiBMRUQgaW5kaWNhdGVzIHRyb3VibGUs?=
	=?utf-8?B?IGFuZCBbUEFUQ0hdIGVuYWJsZS9kaXNhYmxlIG9mIGZvcmNlLWxpbmst?=
	=?utf-8?B?dXA=?=
Date: Fri, 12 Dec 2008 16:41:55 +0900
Message-ID: <20081212164155ohashi-h@mail.jp.nec.com>
References: <20081204182421ohashi-h@mail.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	jgarzik@pobox.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, h-shimamoto@ct.jp.nec.com,
	ohashi-h@mb.dnes.nec.co.jp
To: =?utf-8?B?SmVmZiBLaXJzaGVyIA==?= <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:41021 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756909AbYLLHmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 02:42:20 -0500
In-reply-to: <20081204182421ohashi-h@mail.jp.nec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


ohashi-h@mb.dnes.nec.co.jp wrote (2008/12/04 18:24:21 +0900 )=EF=BC=9A
>
>Jeff Kirsher wrote (2008/12/03 17:12:00 +0900 )=EF=BC=9A
>
>>On Tue, Dec 2, 2008 at 11:36 PM,  <ohashi-h@mb.dnes.nec.co.jp> wrote:
>>> From: Hiroki Ohashi  <ohashi-h@mb.dnes.nec.co.jp>
>>>
>>> Hi all,
>>>
>>> I faced the following situations.
>>> The LED of NIC was indicated, even when the system was not linked
>>> the network (auto-negotiation failed or link partner cannot
>>> auto-negotiate).
>>> LED should be indicate only when the network was linked.
>>> And so, it is a problem that LED indicates.
>>>
>>> I think the indicating the LED is a problem for maintenance.
>>> I cannot know the condition of the link, because I confirm
>>> to link up by LED's indication.
>>>
>>> We are using 82571EB ethernet controler and serdes interface.
>>>
=2E..

>>
>>I am a little confused.  You state you are using an NIC (82571EB)
>>which is currently not supported by e1000, but is supported in the
>>e1000e driver.  Then you suggest a change to the e1000 driver to
>>resolve an issue you see with your 82571EB NIC.
>>
>>So I would suggest you use the e1000e driver first.
>
>Thank you, I will try again using e1000e driver.
>
>>Also the Link LED is supposed to indicated that there is a "physical"
>>link, in which case you can have a physical connection and still fail
>>auto-neg.  So I do not necessarily agree with your interpretation of
>>what a link LED is supposed to indicate.
>
>My explanation was insufficiently.
>My system was NOT connected LAN cable to NIC, but the Link LED
>was indicated.
>So the problem is the LED is indicated without connecting the cable.
>

I tried again using kernel 2.6.27.8 (e1000e driver).
The LED of NIC was indicated, even when the system was not=20
connected LAN cable.
When I deleted logic of force-link-up (the following modification.),
the LED was turned off.

I think it is a problem that LED indicates.
If you have any good way to modify, please let me know.
(Patches are considering.)

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- drivers/net/e1000e/lib.c.org
+++ drivers/net/e1000e/lib.c
@@ -539,8 +539,6 @@ s32 e1000e_check_for_serdes_link(struct=20
                        mac->autoneg_failed =3D 1;
                        return 0;
                }
+#if 0
                hw_dbg(hw, "NOT RXing /C/, disable AutoNeg and force li=
nk.\n");
=20
                /* Disable auto-negotiation in the TXCW register */
@@ -550,7 +548,7 @@ s32 e1000e_check_for_serdes_link(struct=20
                ctrl =3D er32(CTRL);
                ctrl |=3D (E1000_CTRL_SLU | E1000_CTRL_FD);
                ew32(CTRL, ctrl);
+#endif
-
                /* Configure Flow Control after forcing link up. */
                ret_val =3D e1000e_config_fc_after_link_up(hw);
                if (ret_val) {
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Hiroki Ohashi
