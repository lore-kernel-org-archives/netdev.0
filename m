From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 92081] New: skb->len=0 and getting "EOF on netlink" with
 "ip monitor all" (of iproute) when adding a vlan with "bridge vlan add"
Date: Tue, 27 Jan 2015 12:01:23 +0000
Message-ID: <20150127120123.4550d9ca@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:49475 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756925AbbA0MBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 07:01:33 -0500
Received: by mail-pd0-f172.google.com with SMTP id v10so18555515pde.3
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2015 04:01:32 -0800 (PST)
Received: from uryu.home.lan ([144.49.132.22])
        by mx.google.com with ESMTPSA id nj8sm1426455pdb.42.2015.01.27.04.01.29
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Jan 2015 04:01:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 26 Jan 2015 10:15:12 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 92081] New: skb->len=0 and getting "EOF on netlink" with "ip monitor all" (of iproute) when adding a vlan with "bridge vlan add"


https://bugzilla.kernel.org/show_bug.cgi?id=92081

            Bug ID: 92081
           Summary: skb->len=0 and getting "EOF on netlink" with "ip
                    monitor all" (of iproute) when adding a vlan with
                    "bridge vlan add"
           Product: Networking
           Version: 2.5
    Kernel Version: 3.17.6-300
          Hardware: All
                OS: Linux
              Tree: Fedora
            Status: NEW
          Severity: high
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: ramirose@gmail.com
        Regression: No

On Fedora 21, with 3.17.6-300.fc21.x86_64, with iproute-3.16.0-3 (installed
from rpm), 
ip -V:
ip utility, iproute2-ss140804

Running in one terminal:
ip monitor all

And then running in a second terminal this sequence:
ip link add br0 type bridge
bridge vlan add vid 10 dev br0 self

causes the "ip monitor all" to terminate, with "EOF on netlink".

This happens also on older distros of Fedora (Fedora 20 and downward) with
older kernels.

It seems that the reason is that an skb->len is 0 for the netlink notification
which is sent from 
with rtnl_notify() which is invoked from  rtnl_bridge_notify(), which in turn
is invoked from  rtnl_bridge_setlink().

See:
http://lxr.free-electrons.com/source/net/core/rtnetlink.c#L2773

Rami Rosen

-- 
You are receiving this mail because:
You are the assignee for the bug.
