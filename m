From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 60669] New: Kernel panic when using HTB qdisc
Date: Wed, 31 Jul 2013 12:25:32 -0700
Message-ID: <20130731122532.171f76bf@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:63227 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223Ab3GaTZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 15:25:35 -0400
Received: by mail-pd0-f182.google.com with SMTP id r10so1119703pdi.27
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 12:25:35 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-71-109.bvtn.or.frontiernet.net. [50.53.71.109])
        by mx.google.com with ESMTPSA id tr10sm3770634pbc.22.2013.07.31.12.25.34
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 31 Jul 2013 12:25:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 31 Jul 2013 12:18:55 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 60669] New: Kernel panic when using HTB qdisc


https://bugzilla.kernel.org/show_bug.cgi?id=60669

            Bug ID: 60669
           Summary: Kernel panic when using HTB qdisc
           Product: Networking
           Version: 2.5
    Kernel Version: 3.11.0-rc2+
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: vi0oss@gmail.com
        Regression: No

Created attachment 107064
  --> https://bugzilla.kernel.org/attachment.cgi?id=107064&action=edit
Kernel panic output

I'm trying to use HTB qdisc. Using something like this commands:

tc qdisc add dev eth1 root handle 55: htb default 1
tc class add dev eth1 parent 55: classid 55:1 htb rate 50000000
tc class add dev eth1 parent 55: classid 55:2 htb rate 50000000 prio -1
tc class add dev eth1 parent 55: classid 55:3 htb rate 50000000
iptables -t mangle -A OUTPUT -p icmp -j CLASSIFY --set-class 55:2
iptables -t mangle -A OUTPUT -p tcp --dport 5555 -j CLASSIFY --set-class 55:3
ifconfig eth1 192.168.98.2 up
cat /dev/zero | nc 192.168.98.2 5555&
cat /dev/zero | nc 192.168.98.2 5556&

The network connection shall be be fully loaded (so classes compete with each
other).

The "+" in kernel version is because of I am using a patch from bug 58691
(should be unrelated with iptables or traffic shaping).

-- 
You are receiving this mail because:
You are the assignee for the bug.
