From: Ivan Dichev <idichev@obs.bg>
Subject: Slow OOM  in netif_RX function
Date: Thu, 24 Jan 2008 19:28:09 +0200
Message-ID: <4798CAA9.1080005@obs.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from obs.bg ([213.91.169.3]:44226 "EHLO smtp.obs.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752444AbYAXRyO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2008 12:54:14 -0500
Received: from localhost (mail.obs.bg [127.0.0.1])
	by smtp.obs.bg (Postfix) with ESMTP id 1B80F46E93
	for <netdev@vger.kernel.org>; Thu, 24 Jan 2008 19:28:11 +0200 (EET)
Received: from smtp.obs.bg ([127.0.0.1])
	by localhost (mail.obs.bg [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id K-1+qQqY9udK for <netdev@vger.kernel.org>;
	Thu, 24 Jan 2008 19:28:10 +0200 (EET)
Received: from [192.168.14.11] (unknown [192.168.14.11])
	by smtp.obs.bg (Postfix) with ESMTP id 0ED7E46E92
	for <netdev@vger.kernel.org>; Thu, 24 Jan 2008 19:28:10 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
I got problem with my linux router. It has slow persistent OOM
problems from few months ago.
Every working(I mean days when more traffic is generated) day my
router is leaking with 15-20 MB memory and
after 2 weeks the restart is a MUST.
>From /proc/slabinfo I saw that size-2048 and size-512 are growing
rapidly every day when traffic occur.

--------- /proc/slabinfo --------------------
size-2048          20322  20349   2072    3    2 : tunables   24  
12    0 : slabdata   6780   6783      0
size-512           50984  51016    536    7    1 : tunables   32  
16    0 : slabdata   7288   7288      0


I was wondering who is allocating this mem pools and then I changed
the kernel with 2.6.23-rc12 including  options
CONFIG_DEBUG_SLAB=y
CONFIG_DEBUG_SLAB_LEAK=y


Unfortunately changing the kernel didn't solve the mem leak....
Now /proc/slab_allocators is showing that 3c59x driver is allocating
2048 and 512 bytes memory pools
caused by RX function.
--------- from /proc/slab_allocators ------------------------------
7612 size-2048: boomerang_rx+0x33b/0x437 [3c59x]
16018 size-512: boomerang_rx+0x165/0x437 [3c59x]

I was thinking that the 3com driver is bogus, .. but not!
After few days I changed the cards with rtl8139 and now ....
--------- from /proc/slab_allocators ------------------------------
size-2048: 20159 rtl8139_rx+0x155/0x2dc [8139too]
size-1024: 2693 rtl8139_rx+0x155/0x2dc [8139too]
size-512: 50515 rtl8139_rx+0x155/0x2dc [8139too]

the memory leak appear again in the same function(RX).

I did search over the mailing list and found as similar only this
http://www.spinics.net/lists/kernel/old/2003-q4/msg03071.html


For sure it does not depend on kernel version and network
driver(except case if both drivers are bogus :)
Any ideas ?

Ivan

