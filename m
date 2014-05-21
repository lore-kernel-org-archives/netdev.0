From: Linus Gasser <list@markas-al-nour.org>
Subject: Bonding with tun-devices
Date: Wed, 21 May 2014 14:59:22 +0100
Message-ID: <537CB13A.3030100@markas-al-nour.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from virt.linusetviviane.ch ([78.46.227.60]:44507 "EHLO
	mail.profeda.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1750877AbaEUOGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 10:06:04 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.profeda.org (Postfix) with ESMTP id 744DBCE24C
	for <netdev@vger.kernel.org>; Wed, 21 May 2014 15:58:53 +0200 (CEST)
Received: from mail.profeda.org ([127.0.0.1])
	by localhost (mail.profeda.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id YnqH-mHg3IOD for <netdev@vger.kernel.org>;
	Wed, 21 May 2014 15:58:51 +0200 (CEST)
Received: from mbp-linus.profeda.org (unknown [78.46.227.54])
	(Authenticated sender: ineiti@linusetviviane.ch)
	by mail.profeda.org (Postfix) with ESMTPSA id 74795CE0D1
	for <netdev@vger.kernel.org>; Wed, 21 May 2014 15:58:50 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear list,

I'm trying to create a bonded interface using tun-devices created by the

ssh -NTCf -w 0:0

command. The reason is that I'm behind a satellite connection with 
per-stream limited bandwidth...

On some older kernels everything was fine, and I could do:

# ssh -NTCf -w 0:0 web
# ssh -NTCf -w 1:1 web
# modprobe bonding mode=0 miimon=100
# ifconfig bond0 172.16.0.1 netmask 255.255.255.0
# ifconfig bond0 hw ether 12:34:56:78:9a
# ifenslave bond0 tun0 tun1

on one side and

# modprobe bonding mode=0 miimon=100
# ifconfig bond0 172.16.0.2 netmask 255.255.255.0
# ifconfig bond0 hw ether 12:35
# ifenslave -f bond0 tun0 tun1
# ping 172.16.0.1

on the other side. On a newer kernel (>3.14) this doesn't work (at least 
not on linux-armv7), while on 3.13 it does work under linux-armv7. Now 
I've been told to use the iproute2-suite, as ifenslave is deprecated. 
But if I try to do

# ssh -NTCf -w 0:0 web
# ssh -NTCf -w 1:1 web
# ip link add name bond1 type bond
# ip link set dev tun0 master bond1

it gives me an error

RTNETLINK answers: Operation not supported

Any idea what I'm doing wrong?

Linus
