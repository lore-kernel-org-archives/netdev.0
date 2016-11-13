From: Mason <slash.tmp@free.fr>
Subject: Debugging Ethernet issues
Date: Sun, 13 Nov 2016 01:01:14 +0100
Message-ID: <5827AD4A.7010908@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Mans Rullgard <mans@mansr.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Tom Lendacky <thomas.lendacky@amd.com>,
        Zach Brown <zach.brown@ni.com>, Andrew Lunn <andrew@lunn.ch>,
        Shaohui Xie <shaohui.xie@nxp.com>,
        Tim Beale <tim.beale@alliedtelesis.co.nz>,
        Brian Hill <brian@houston-radar.com>,
        Vince Bridgers <vbridgers2013@gmail.com>,
        Balakumaran Kannan <kumaran.4353@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Sebastian Frias <sf84@laposte.net>,
        Kirill Kapranov <kapranoff@inbox.ru>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:57042 "EHLO smtp2-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750979AbcKMABx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 12 Nov 2016 19:01:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello everyone,

In a past thread ("Ethernet not working on a different SoC with
same eth HW") I was struggling getting Ethernet to work at all on
a new board using a recent 4.7 kernel.

After much hair-pulling, it turned out that *some* of the breakage
was caused by a local patch which should have been guarded by a
preprocessor macro.

But even after reverting that patch, Ethernet does not work well
on this board with kernel 4.7 whereas if I use an ancient 3.4 kernel,
then Ethernet works much better.

Differences:

When connected to a 100 Mbps switch
3.4 negotiates a LAN DHCP setup instantly
4.7 times out

When connected to a Gigabit switch
3.4 negotiates a LAN DHCP setup instantly
4.7 requires over 5 seconds to do so

(In case it matters, my board is using an Atheros 8035 PHY.)

I am aware that there have been hundreds of patches to the phy
and net frameworks in the 3.4 to 4.7 time-frame. I'm wondering
if there are important events I can log, to see what is going
wrong in the 4.7 case?

Are there kernel debugging options I might turn on, to better
understand what is going wrong?

I would be extremely grateful for any insight on this subject.

Regards.
