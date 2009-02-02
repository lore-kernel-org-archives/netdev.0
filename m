From: Wes Chow <wchow@athenacr.com>
Subject: Re: Multicast packet loss
Date: Mon, 2 Feb 2009 19:51:21 +0000 (UTC)
Message-ID: <loom.20090202T194942-55@post.gmane.org>
References: <49833DBC.7040607@athenacr.com> <20090130200330.GA12659@hmsreliant.think-freely.org> <49837F56.2020502@athenacr.com> <49838213.90700@cosmosbay.com> <49859847.9010206@cosmosbay.com> <20090202134523.GA13369@hmsreliant.think-freely.org> <498725F4.2010205@cosmosbay.com> <20090202182212.GA17950@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:48779 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752906AbZBBTzE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Feb 2009 14:55:04 -0500
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1LU4so-0005QW-Jj
	for netdev@vger.kernel.org; Mon, 02 Feb 2009 19:55:02 +0000
Received: from 454a27d2.cst.lightpath.net ([69.74.39.210])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 02 Feb 2009 19:55:02 +0000
Received: from wchow by 454a27d2.cst.lightpath.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 02 Feb 2009 19:55:02 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



(I'm Kenny's colleague, and I've been doing the kernel builds)

First I'd like to note that there were a lot of bnx2 NAPI changes between 
2.6.21 and 2.6.22. As a reminder, 2.6.21 shows tiny amounts of packet loss,
whereas loss in 2.6.22 is significant.

Second, some CPU affinity info: if I do like Eric and pin all of the
apps onto a single CPU, I see no packet loss. Also, I do *not* see
ksoftirqd show up on top at all!

If I pin half the processes on one CPU and the other half on another CPU, one 
ksoftirqd processes shows up in top and completely pegs one CPU. My packet loss
in that case is significant (25%).

Now, the strange case: if I pin 3 processes to one CPU and 1 process to 
another, I get about 25% packet loss and ksoftirqd pins one CPU. However, one
of the apps takes significantly less CPU than the others, and all apps lose the
*exact same number of packets*. In all other situations where we see packet
loss, the actual number lost per application instance appears random.

We're about to plug in an Intel ethernet card into this machine to collect more 
rigorous testing data. Please note, though, that we have seen packet loss with
a tg3 chipset as well. For now, though, I'm assuming that this is purely a bnx2
problem.

If I understand correctly, when the nic signals a hardware interrupt, the 
kernel grabs it and defers the meaty work to the softirq handler -- how does it
decide which ksoftirqd gets the interrupts? Is this something determined by how
the driver implements the NAPI?


Wes


