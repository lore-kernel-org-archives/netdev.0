From: Andrew Gallatin <gallatin@myri.com>
Subject: How do I use multiqueue tx
Date: Tue, 03 Jun 2008 11:34:18 -0400
Message-ID: <4845647A.7060002@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1847 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751649AbYFCQBc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2008 12:01:32 -0400
Received: from [172.31.134.217] (drew2-ovpn.sw.myri.com [172.31.134.217])
	by myri.com (8.13.7+Sun/8.13.7) with ESMTP id m53FYmnP001235
	for <netdev@vger.kernel.org>; Tue, 3 Jun 2008 08:34:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've done a patch to myri10ge which enables the use of multiple
transmit queues in our Linux driver using CONFIG_NETDEVICES_MULTIQUEUE
netdev subqueues.  Our current hardware uses multiple queues purely
for increasing host parallelism, not priority/QOS.  I'm looking for a
way, beyond pktgen, to actually use any transmit queue other than 0 to
increase parallelism.

Ideally, we would like to support hashing connections on egress to the
same tx/rx queue pair (and hence MSI-X irq) as our device will hash
the traffic to on ingress.  As far as I can tell, the qdisc layer is
where this hashing currently must happen.  Is this correct?  Or is
there a hook which would allow a driver to supply a hash function to
select the egress queue prior to its transmit function being called?

Otherwise, is my only option to write an entire new qdisc which does
the same sort of hashing as our nic, and force the admin to use tc to
select my custom qdisc?

Thanks,

Drew
