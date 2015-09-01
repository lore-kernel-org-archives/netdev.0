From: footplus@gmail.com
Subject: Prioritize a vlan on another
Date: Tue, 1 Sep 2015 23:07:00 +0200
Message-ID: <266BF78D-5C37-40E1-A065-1426CC2325E2@gmail.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:35029 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751461AbbIAVHG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 17:07:06 -0400
Received: by wicge5 with SMTP id ge5so20339523wic.0
        for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 14:07:04 -0700 (PDT)
Received: from [192.168.240.101] (soy95-8-78-225-91-189.fbx.proxad.net. [78.225.91.189])
        by smtp.gmail.com with ESMTPSA id o9sm28995686wja.29.2015.09.01.14.07.02
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Sep 2015 14:07:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I'm not sure if this is the right place to ask this, but i'm stuck on a=
 trafic priority problem since some time.

I have 2 10Gb interfaces (bnx2x) bonded in a 802.3ad aggregate. On this=
 aggregate, 2 vlans are configured (let's INT and EXT) I need to ensure=
 that, when sending traffic at near line rate via EXT, all packets targ=
eted to INT are sent in priority (dropping EXT traffic as needed).

My devices have the mq qdisc by default (running CentOS 7, kernel 3.10)=
=2E

After googling for documentation about the mq qdisc, I saw it was a stu=
b to have one root qdisc per tx queue, so I expected that below were st=
andard pfifo_fast qdiscs and that I should be able to just mark traffic=
 as Minimize-Delay via iptable's TOS target, but it seems that it has n=
o visible effect when mq+pfifo_fast are in effect.

I played with various qdiscs, and I think I got the right behavior when=
 replacing the mq root qdisc by a prio qdisc (along with using TOS targ=
et), but then I was loosing the per-queue lock aspect of the mq qdisc. =
I did not manage to reproduce this with mq yet.

Could you recommend a way of achieving my goal with the maximum perform=
ance ?

Should more details be needed about my setup, i'll collect and send the=
m.

Thanks for your help,

Best regards,
--=20
Aur=C3=A9lien