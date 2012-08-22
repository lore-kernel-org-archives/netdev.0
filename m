From: Roland Dreier <roland@kernel.org>
Subject: Best way to set kernel thread affinity for handling a socket?
Date: Wed, 22 Aug 2012 09:10:37 -0700
Message-ID: <CAG4TOxNMRR_-bYJV1a_je2HKrpmVuGubH9ks4GdG8Shwa92K0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:52761 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755035Ab2HVQK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 12:10:58 -0400
Received: by qaas11 with SMTP id s11so4610310qaa.19
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 09:10:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi everyone,

Let's say I have kernel code that's sitting in a loop doing
kernel_accept() on a TCP socket.  As each connection comes in, it
forks off a kernel thread to deal with that socket.

If I have a modern NIC with RSS and multiple queues, each TCP flow is
going to be steered to one queue, which is probably bound to one CPU.
So when I fork off that kernel thread, I'd like to bind it to the CPU
where its NIC queues are going to be processed.  My question is, how
do I find out which CPU that is?  Is there anything in the new socket
structure I get back from kernel_accept() that I can look at to know
which CPU the packets came in on?

I'm thinking about this in the context of the kernel's iSCSI target
code (drivers/target/iscsi), which creates threads to handle each
iSCSI connection and sets their CPU affinity pretty much randomly
(well, based on some "thread id", cf iscsit_thread_get_cpumask()).
And with a modern NIC, this leads to packets being received on one CPU
but the data being consumed on another CPU, all the time, which is
obviously far from optimal.

Thanks!
  Roland
