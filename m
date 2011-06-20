From: Dave Jones <davej@redhat.com>
Subject: iscsi related softlockup (3.0 rc3)
Date: Mon, 20 Jun 2011 16:00:59 -0400
Message-ID: <20110620200059.GA21401@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33368 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751942Ab1FTUBD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jun 2011 16:01:03 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p5KK125w022100
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 16:01:02 -0400
Received: from gelk.kernelslacker.org (ovpn-113-108.phx2.redhat.com [10.3.113.108])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p5KK11Eo032022
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 16:01:02 -0400
Received: from gelk.kernelslacker.org (gelk [127.0.0.1])
	by gelk.kernelslacker.org (8.14.5/8.14.4) with ESMTP id p5KK10eL024203
	for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 16:01:00 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.5/8.14.5/Submit) id p5KK0x7V024189
	for netdev@vger.kernel.org; Mon, 20 Jun 2011 16:00:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I made some changes to my syscall fuzzer as it hasn't been turning up anything
interesting since the last lot of problems got fixed.  I seem to have found
a way to get iscsi really confused, to the point that the soft-lockup detector
kicks in, and then the rcu stall detector.

http://davej.fedorapeople.org/iscsi-lockup.txt is the dmesg from the box.
sysrq was working, but I couldn't ssh into the box, or even log in on the console.
I had ssh sessions already logged into the box which were completely wedged.

I don't have any iscsi setup configured on this machine, the fuzzer just hit upon
that protocol randomly.  If it wasn't for the fact that the machine wedged I wouldn't
be overly concerned, but it seems that something got into a state that just consumed
all cpu time.

	Dave

