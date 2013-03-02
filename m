From: Andre Heider <a.heider@gmail.com>
Subject: atl1c: DMA: Out of SW-IOMMU space
Date: Sat, 2 Mar 2013 18:28:57 +0100
Message-ID: <CAHsu+b8JkVPbh7p7pj4u2XFJ3oA+HfxiGVJyz7TLG3FNQzBZCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, xiong@qca.qualcomm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:40343 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980Ab3CBR26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Mar 2013 12:28:58 -0500
Received: by mail-pb0-f45.google.com with SMTP id ro8so2325311pbb.18
        for <netdev@vger.kernel.org>; Sat, 02 Mar 2013 09:28:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

my "AR8151 v2.0 Gigabit Ethernet (rev c0)" becomes unusable on v3.8
after some usage.

It's easily reproducible with "dd if=/dev/zero of=<nfsshare>/test
bs=1M count=2048. Point of failure varies, but somewhat after >1.5gb
of data written to the nfs server dmesg gets spammed with "DMA: Out of
SW-IOMMU space for x bytes at device 0000:06:00.0" (where x varies)
and all sorts of follow up problems start occurring.
Apparently I'm not the only one affected:
https://www.google.com/search?q=atl1c+%22DMA%3A+Out+of+SW-IOMMU+space%22

The problem doesn't exist on v3.8-rc7.

The only atl1c commit in v3.8-rc7..v3.8 is:

commit ac574804d412047e52de4dd887615cc88f58aeb0
Author: Huang, Xiong <xiong@qca.qualcomm.com>
Date:   Mon Feb 11 14:44:40 2013 +0000

    atl1c: add error checking for pci_map_single functions

    it is reported that code hit DMA-API errors on 3.8-rc6+,
    (see https://bugzilla.redhat.com/show_bug.cgi?id=908436, and
         https://bugzilla.redhat.com/show_bug.cgi?id=908550)

    this patch just adds error handler for
        pci_map_single and skb_frag_dma_map.

    Signed-off-by: xiong <xiong@qca.qualcomm.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Reverting that on top of v3.8 seems to fix the problem in my little
testing, so it sounds like that fix introduced a iommu leak?

Thanks,
Andre
