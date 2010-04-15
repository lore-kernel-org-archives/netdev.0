From: "George B." <georgeb@gmail.com>
Subject: Network multiqueue question
Date: Thu, 15 Apr 2010 09:58:34 -0700
Message-ID: <i2tb65cae941004150958n5c66dc42j26724bbb075125a0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:41310 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754912Ab0DOQ6f convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 12:58:35 -0400
Received: by pwj9 with SMTP id 9so1295529pwj.19
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 09:58:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am in need of a little education on multiqueue and was wondering if
someone here might be able to help me.

Given intel igb network driver, it appears I can do something like:

=A0tc qdisc del dev eth0 root handle 1: multiq

which works and reports 4 bands:=A0 dev eth0 root refcnt 4 bands 4/4

But our network is a little more complicated.=A0 Above the ethernet we
have the bonding driver which is using mode 2 bonding with two
ethernet slaves.=A0 Then we have vlans on the bond interface.=A0 Our
production traffic is on a vlan and resource contention is an issue as
these are busy machines.

It is my understanding that the vlan driver became multiqueue aware in
2.6.32 (we are currently using 2.6.31).

It would seem that the first thing the kernel would encounter with
traffic headed out would be the vlan interface, and then the bond
interface, and then the physical ethernet interface.=A0 Is that correct=
?
 So with my kernel, I would seem to get no utility from multiq on the
ethernet interface if the vlan interface is going to be a
single-threaded bottleneck.=A0 What about the bond driver?=A0 Is it
currently multiqueue aware?

I am try to get some sort of logical picture of how all these things
interact with each other to get things a little more efficient and
reduce resource contention in the application while still trying to be
efficient in use of network ports/interfaces.

If someone feels up to the task of sending a little education my way,
I would be most appreciative.=A0 There doesn't seem to be a whole lot o=
f
documentation floating around about multiqueue other than a blurb of
text in the kernel and David's presentation of last year.

Thanks!

George
