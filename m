From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 61681] New: Incoming TCP4 connections fail to start, don't
 get past SYN_RECV and then quickly disappear
Date: Thu, 19 Sep 2013 22:18:50 -0700
Message-ID: <20130919221850.77620129@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:57168 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753305Ab3ITFSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 01:18:55 -0400
Received: by mail-pa0-f49.google.com with SMTP id ld10so279734pab.22
        for <netdev@vger.kernel.org>; Thu, 19 Sep 2013 22:18:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 19 Sep 2013 09:42:15 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 61681] New: Incoming TCP4 connections fail to start, don't get past SYN_RECV and then quickly disappear


https://bugzilla.kernel.org/show_bug.cgi?id=61681

            Bug ID: 61681
           Summary: Incoming TCP4 connections fail to start, don't get
                    past SYN_RECV and then quickly disappear
           Product: Networking
           Version: 2.5
    Kernel Version: Linux xxxxxx 3.4.57-48.42.amzn1.x86_64 #1 SMP Mon Aug
                    12 21:43:36 UTC 2013 x86_64 x86_64 x86_64 GNU/Linux
          Hardware: IA-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: dcrooke@gmail.com
        Regression: No

This bug appears to be very rare, but entirely real, and it dates back a long
time. I tried to debug it thoroughly looking at both kernel and webserver
settings, and then got down to looking at netstat.

The Linux kernel can sometimes get into a state where it fails to complete
approx 98% of incoming TCP connection attempts, and only correctly processes
about 2%. These numbers may be relevant as others have posted finding the same
"1 in 50" ratio on much older kernels over the years.

I did not get a chance to capture traffic with iptables / pcap / Wireshark
(production box so we gave up quickly and tried a reboot) but other folks with
the same issue indicate that Linux is sending the wrong remote sequence number
back in the SYN-ACK packet, and the client simply drops it. My experience is
that the half formed connection is torn down almost immediately - I was running
netstat in a continuous loop to see this, others have observed that their
clients send RST in response to the malformed SYN-ACK.

http://serverfault.com/questions/297134/server-not-sending-a-syn-ack-packet-in-response-to-a-syn-packet

http://ask.wireshark.org/questions/23885/rst-after-syn-ack

For us, the problem went away on a reboot and so far has stayed away, so I am
wondering if it is a factor of cumulative traffic but TCP sequence number
wraparound on the Linux end shouldn't cause this afaict, it should be simply
replying to the client with the sequence number that came in the SYN packet.

A number of people have had very similar looking issues due to broken
multi-path network config or a broken NAT device. Obviously this is not the
case here, Amazon knows how to do IT, this box only has one interface, and in
any case the Linux kernel is still responsible for the sequence number it
replies with.

-- 
You are receiving this mail because:
You are the assignee for the bug.
