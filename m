From: Rune Magnussen <rum@bankdata.dk>
Subject: [BISECTED] Linux 3.2: Networking out of LAN does not work
Date: Wed, 25 Jan 2012 10:35:37 +0100
Message-ID: <OF0BD4E9BA.3C3D7E41-ONC1257990.0034993D-C1257990.0034B2CE@bdpnet.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.bankdata.dk ([194.239.188.13]:34894 "HELO mx4.bankdata.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751036Ab2AYJft (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jan 2012 04:35:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Networking to and from the outside of my LAN does not work with Linux 
3.2.x.
Linux 3.1.x works. Using ssh from a PC on the LAN also works.
The machine has a VIA C7 CPU and the NIC uses the 8139too-driver.

Another machine with a r8169-NIC and an Atom-CPU (32bit) did not 
show any problems.
It was used very ligtly though.

Bisection led to this:
---
f04565ddf52e401880f8ba51de0dff8ba51c99fd is the first bad commit
commit f04565ddf52e401880f8ba51de0dff8ba51c99fd
Author: Mihai Maruseac <mihai.maruseac@gmail.com>
Date:   Thu Oct 20 20:45:10 2011 +0000

    dev: use name hash for dev_seq_ops
 
    Instead of using the dev->next chain and trying to resync at each call 
to
    dev_seq_start, use the name hash, keeping the bucket and the offset in
    seq->private field.
 
    Tests revealed the following results for ifconfig > /dev/null
       * 1000 interfaces:
          * 0.114s without patch
          * 0.089s with patch
       * 3000 interfaces:
          * 0.489s without patch
          * 0.110s with patch
       * 5000 interfaces:
          * 1.363s without patch
          * 0.250s with patch
       * 128000 interfaces (other setup):
          * ~100s without patch
          * ~30s with patch
 
    Signed-off-by: Mihai Maruseac <mmaruseac@ixiacom.com>
    Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 2e86e1c9ecaf719d312a8b5863ec9e89d92bc4b3 
8b0d09ca105502dd5389bb6281ef059c8bb38667 M   net
---

Simply reverting the commit on top of Linux 3.2.1 resultet in a build 
error.

Used kernel configuration: http://knus.info/kernel/config-3.1.txt

Greetings Rune
