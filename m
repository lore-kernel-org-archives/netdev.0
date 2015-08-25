From: John Nielsen <lists@jnielsen.net>
Subject: vxlan regression: multiple VXLANs on a single multicast group broken in kernel 4.1
Date: Tue, 25 Aug 2015 11:35:21 -0600
Message-ID: <1F0A5B2B-5C6D-426F-91E9-A7A2F11A98A9@jnielsen.net>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: marcelo.leitner@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail2.jnielsen.net ([50.114.224.20]:57031 "EHLO
	webmail2.jnielsen.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755756AbbHYSEz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 14:04:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After updating the kernel on a KVM host, I discovered yesterday that I =
can no longer use more than one vxlan interface on a single multicast g=
roup/address. The interfaces can be created but only the first one may =
be brought up:

# ip link add vx100 type vxlan id 100 group 239.0.0.1 dev eth0
# ip link add vx200 type vxlan id 200 group 239.0.0.1 dev eth0
# ip link set up dev vx100
# ip link set up dev vx200
RTNETLINK answers: Address already in use

Using unique group addresses (one VNI per group) still works as expecte=
d. The problem is not present in kernel 4.0.5 but it is in kernel 4.1.0=
=2E

I suspect (but have not verified) that the regression was caused by thi=
s commit:
vxlan: Move socket initialization to within rtnl scope 56ef9c909b40483d=
2c8cb63fcbf83865f162d5ec

https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/co=
mmit/drivers/net/vxlan.c?id=3D56ef9c909b40483d2c8cb63fcbf83865f162d5ec

I am working to verify that that is the culprit but I thought I=E2=80=99=
d see in the mean time if anyone else has encountered and/or fixed this=
, or can at least shed more light on the problem.

Thanks!

JN
