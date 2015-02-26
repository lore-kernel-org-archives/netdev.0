From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 93861] New: Problem in source route of interfaces
Date: Wed, 25 Feb 2015 16:27:00 -0800
Message-ID: <20150225162700.671e558e@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:50351 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752748AbbBZA1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 19:27:00 -0500
Received: by mail-ig0-f177.google.com with SMTP id z20so10529787igj.4
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 16:26:59 -0800 (PST)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id m5sm174712ige.5.2015.02.25.16.26.59
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Feb 2015 16:26:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 25 Feb 2015 14:54:29 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 93861] New: Problem in source route of interfaces


https://bugzilla.kernel.org/show_bug.cgi?id=93861

            Bug ID: 93861
           Summary: Problem in source route of interfaces
           Product: Networking
           Version: 2.5
    Kernel Version: 3.10.0
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: kidboy@brturbo.com.br
        Regression: No

I have 2 internet links, where do a test to assess the connection applying a
ping on each output interface and getting the result, in version 2.6.XX i can
ping and route source works fine, but in kernel 3.X.XX its not work anymore, i
dont know why.

My configuration is here:

/etc/sysconfig/network-scripts/ifcfg-eth0
TYPE="Ethernet"
BOOTPROTO="static"
IPV4_FAILURE_FATAL="no"
NAME="eth0"
UUID="68ec71ab-62f4-41fc-9ad8-085bb3b78eae"
ONBOOT="yes"
HWADDR="10:FE:ED:07:B3:38"
IPADDR="192.168.25.2"
GATEWAY="192.168.25.1"
PREFIX="24"
NM_CONTROLLED="no"

/etc/sysconfig/network-scripts/ifcfg-eth1
TYPE="Ethernet"
BOOTPROTO="static"
IPV4_FAILURE_FATAL="no"
NAME="eth1"
UUID="6ddee48f-3296-4158-86e6-d4104593d942"
ONBOOT="yes"
HWADDR="50:E5:49:FB:AF:0D"
IPADDR="192.168.26.2"
GATEWAY="192.168.26.1"
PREFIX="24"
NM_CONTROLLED="no"

# /etc/rc.d/rc.local ( Permission is 755 in file )
ip route add 192.168.25.0 dev eth0 src 192.168.25.2 table 1
ip route add default via 192.168.25.1 table 1

# Rules for out ADSL1
ip route add 192.168.26.0 dev eth1 src 192.168.26.2 table 2
ip route add default via 192.168.26.1 table 2
# Rules for out ADSL2
ip route add 192.168.25.0 dev eth0 src 192.168.25.2
ip route add 192.168.26.0 dev eth1 src 192.168.26.2
# Rule for tables
ip rule add from 192.168.25.0 table 1
ip rule add from 192.168.26.0 table 2
ip rule add fwmark 1 lookup 1
ip rule add fwmark 2 lookup 2
ip route flush cached


So if i use command 'ping -I192.168.25.2 8.8.8.8' its work fine because its the
default route of system, but if i use command 'ping -I192.168.26.2 8.8.8.8' its
not work, in tcpdump report its out using lo interface. In kernel 2.6 the
output of tcpdump is the interface 192.168.26.2 and works fine. I dont know
what change for new kernel or if its a bug. The forwarding is enable,
configuration in kernel 2.6 and 3.x is the same.

-- 
You are receiving this mail because:
You are the assignee for the bug.
