From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: e1000: Question about polling
Date: Mon, 18 Feb 2008 12:18:20 +0300
Message-ID: <47B94D5C.2070509@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:55970 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751099AbYBRJS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 04:18:28 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.bigtelecom.ru (Postfix) with ESMTP id AED73A6C414
	for <netdev@vger.kernel.org>; Mon, 18 Feb 2008 12:18:26 +0300 (MSK)
Received: from mail.bigtelecom.ru ([127.0.0.1])
	by localhost (mail.bigtelecom.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 5sYN5ROqEm-4 for <netdev@vger.kernel.org>;
	Mon, 18 Feb 2008 12:18:20 +0300 (MSK)
Received: from [87.255.0.131] (slavon.bigtelecom.ru [87.255.0.131])
	by mail.bigtelecom.ru (Postfix) with ESMTP id B561BA6C42D
	for <netdev@vger.kernel.org>; Mon, 18 Feb 2008 12:18:20 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all.

Interesting think:

Have PC that do NAT. Bandwidth about 600 mbs.

Have  4 CPU (2xCoRe 2 DUO "HT OFF" 3.2 HZ).

irqbalance in kernel is off.

nat2 ~ # cat /proc/irq/217/smp_affinity
00000001
nat2 ~ # cat /proc/irq/218/smp_affinity
00000003

Load SI on CPU0 and CPU1 is about 90%

Good... try do
echo ffffffff > /proc/irq/217/smp_affinity
echo ffffffff > /proc/irq/218/smp_affinity

Get 100% SI at CPU0

Question Why?

I listen that if use IRQ from 1 netdevice to 1 CPU i can get 30% 
perfomance... but i have 4 CPU... i must get more perfomance if i cat 
"ffffffff"  to smp_affinity.

picture looks liks this:
0-3 CPU get over 50% SI.... bandwith up.... 55% SI... bandwith up... 
100% SI on CPU0....

I remember patch to fix problem like it... patched function 
e1000_clean...  kernel on pc have this patch (2.6.24-rc7-git2)... e1000 
driver work much better (i up to 1.5-2x bandwidth before i get 100% SI), 
but i think that it not get 100% that it can =)

Thanks for answers and sorry for my English


