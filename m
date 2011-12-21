From: Michal Simek <monstr@monstr.eu>
Subject: ICMP packets - ll_temac with Microblaze
Date: Wed, 21 Dec 2011 11:11:37 +0100
Message-ID: <4EF1B0D9.2010007@monstr.eu>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	John Williams <john.williams@petalogix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:40594 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751652Ab1LUKLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 05:11:41 -0500
Received: by eekc4 with SMTP id c4so7390231eek.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 02:11:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric and David,

I have found one problem with ll_temac driver and
this commit: net: more accurate skb truesize
sha1: 87fb4b7b533073eeeaed0b6bf7c2328995f6c075

The problem is only with icmp packets from the target. It is sent and driver receive it
but it is not proceed to the application.

The problem I see is that kmalloc_node_track_caller allocate
specific size and then this size is changed by SKB_WITH_OVERHEAD(ksize(data)).
The problem is with netdev_alloc_skb_ip_align which calls __alloc_skb function.

Currently driver uses setting for jumbo frames (9k). When I change it to use mtu (1,5k) then
everything is ok.

Can you give me some hints what can be wrong?

Thanks,
Michal


-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian
