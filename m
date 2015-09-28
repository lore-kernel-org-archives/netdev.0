From: Christoffer Dall <christoffer.dall@linaro.org>
Subject: BUG: Mellanox crash with iommu=soft and swiotlb=force
Date: Mon, 28 Sep 2015 23:04:50 +0200
Message-ID: <20150928210450.GA7610@cbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ian.campbell@citrix.com, stefano.stabellini@eu.citrix.com,
	konrad.wilk@oracle.com
To: amirv@mellanox.com, idos@mellanox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:34924 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751998AbbI1VEv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 17:04:51 -0400
Received: by laer8 with SMTP id r8so45798292lae.2
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 14:04:49 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

In doing some performance experiments I found that using a 10G Mellanox
MX354A Dual port FDR CX3 device on a server running Apache and running
ab against that server causes the system to crash with 'iommu=soft
swiotlb=force'.  The same behavior is seen without these options on Dom0
running under Xen.

I have tried this on v4.0 and v4.3-rc3.

Examples of crashes:
http://pastebin.ubuntu.com/11953498/
http://pastebin.ubuntu.com/11953443/

Kernel config (v4.3):
http://paste.ubuntu.com/12605446/

To reproduce, host a file in apache server on a system with the Mellanox
NIC (I used the 41K index file of the GCC manual) and run ab (apache
bench) from a client machine, something like this:

$ ab -n 100000 -c 100 http://10.10.1.2/gcc/index.html

I'm afraid debugging this is out of my area of expertise.  Is this
something you could have a look at?


Thanks,
-Christoffer
