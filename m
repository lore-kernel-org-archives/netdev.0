From: Jan Engelhardt <jengelh@medozas.de>
Subject: tcpdump broke in 2.6.34-rc1
Date: Fri, 12 Mar 2010 13:39:07 +0100 (CET)
Message-ID: <alpine.LSU.2.01.1003120037050.22042@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:59261 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751582Ab0CLMjN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Mar 2010 07:39:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings.


I am currently on 2.6.34-rc1 and found that tcpdump no 
longer works (dies with setsockopt: invalid argument). Bisect-narrowed 
it down to somewhere between

# good: [13dda80e48439b446d0bc9bab34b91484bc8f533] Merge branch 'davinci-for-lin
# bad: [b7f3a209e9b09b3110ea084836c75f2cd26b29f2] Merge git://git.kernel.org/pub

(bisecting in there gives me even a kernel panic on boot. Great fun. So 
I'm leaving it at that.)
The strace output is:

socket(PF_PACKET, SOCK_RAW, 768)        = 3
ioctl(3, SIOCGIFINDEX, {ifr_name="lo", ifr_index=1}) = 0
ioctl(3, SIOCGIFHWADDR, {ifr_name="eth0", ifr_hwaddr=08:00:27:6e:34:4a}) = 0
ioctl(3, SIOCGIFINDEX, {ifr_name="eth0", ifr_index=2}) = 0
bind(3, {sa_family=AF_PACKET, proto=0x03, if2, pkttype=PACKET_HOST, addr(0)={0,
}, 20) = 0
getsockopt(3, SOL_SOCKET, SO_ERROR, [17179869184], [4]) = 0
setsockopt(3, SOL_PACKET, PACKET_ADD_MEMBERSHIP,
"\2\0\0\0\1\0\0\0\0\0\0\0\0\0\0\0", 16) = -1 EINVAL (Invalid argument)


