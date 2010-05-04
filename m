From: "George B." <georgeb@gmail.com>
Subject: Question about vlans, bonding, etc.
Date: Mon, 3 May 2010 17:06:59 -0700
Message-ID: <i2tb65cae941005031706o19a6f1e9zc86b33d73462113f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:34177 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756678Ab0EDAHA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 20:07:00 -0400
Received: by pxi5 with SMTP id 5so526818pxi.19
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 17:06:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Watching the "Receive issues with bonding and vlans" thread brought a
question to mind. =A0In what order should things be done for best
performance?

=46or example, say I have a pair of ethernet interfaces. =A0Do I slave =
the
ethernet interfaces to the bond device and then make the vlans on the
bond devices?
Or do I make the vlans on the ethernet devices and then bond the vlan
interfaces?

In the first case I would have:



bond0.3--|     |------eth0
             bond0
bond0.5--|     |------eth1

The second case would be:

      |------------------eth0.5-----|
      |          |-------eth0.3---eth0
bond0  bond1
      |          |-------eth1.3---eth1
      |------------------eth1.5-----|

I am using he first method currently as it seemed more intuitive to me
at the time to bond the ethernets and then put the vlans on the bonds
but it seems life might be easier for the vlan driver if it is bound
directly to the hardware.  I am using Intel NICs (igb driver) with 4
queues per NIC.

Would there be a performance difference expected between the two
configurations?  Can the vlan driver "see through" the bond interface
to the
hardware and take advantage of multiple queues if the hardware
supports it in the first configuration?

George Bonser
