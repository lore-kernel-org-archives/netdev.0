From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 99081] New: Bridge multicast snooping breaks ICMPv6
Date: Thu, 28 May 2015 07:35:39 -0700
Message-ID: <20150528073539.2619267a@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35165 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbbE1Ofk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 10:35:40 -0400
Received: by pacwv17 with SMTP id wv17so24968023pac.2
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 07:35:40 -0700 (PDT)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id om10sm2612059pbb.58.2015.05.28.07.35.39
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 May 2015 07:35:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 28 May 2015 10:34:55 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 99081] New: Bridge multicast snooping breaks ICMPv6


https://bugzilla.kernel.org/show_bug.cgi?id=99081

            Bug ID: 99081
           Summary: Bridge multicast snooping breaks ICMPv6
           Product: Networking
           Version: 2.5
    Kernel Version: 4.0.4
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: sgunderson@bigfoot.com
        Regression: No

Hi,

I've seen this reported many times around the net, with no definite solution;
since I got hit by it again and now used the latest kernel, I thought the best
place would be the kernel Bugzilla.

I have a bridge br0 with eth0 on it, and then some tap devices from KVM guests.
In this situation, by default, I don't have IPv6. I can't ping anything because
ND fails. I've seen this over multiple kernel versions for years, so I'm fairly
certain this is not something about my specific setup.

The common workaround is:

 echo 0 > /sys/devices/virtual/net/br0/bridge/multicast_snooping 

which immediately makes IPv6 work well again.

IPv6 unicast is unaffected; only multicast (ie., ND) seems to have the problem.

-- 
You are receiving this mail because:
You are the assignee for the bug.
