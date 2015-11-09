From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 107551] New: IPV4 Reassembling Problem
Date: Mon, 9 Nov 2015 10:40:01 -0800
Message-ID: <20151109104001.09d86030@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33585 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751691AbbKISjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 13:39:51 -0500
Received: by pabfh17 with SMTP id fh17so207070821pab.0
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2015 10:39:50 -0800 (PST)
Received: from xeon-e3 (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by smtp.gmail.com with ESMTPSA id w11sm10287548pbs.87.2015.11.09.10.39.50
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 10:39:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Mon, 9 Nov 2015 11:04:29 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 107551] New: IPV4 Reassembling Problem


https://bugzilla.kernel.org/show_bug.cgi?id=107551

            Bug ID: 107551
           Summary: IPV4 Reassembling Problem
           Product: Networking
           Version: 2.5
    Kernel Version: 4.2.3
          Hardware: Other
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: bernd.weiberg@siemens.com
        Regression: No

I have an ipv4 reassembling issue using the latest Kernel (4.2.3) in an nios2
environment.
I first noticed that issue when sending UDP-Pakets from an Host PC to my
device. Each packet has a payload of 4096 Byte.
Due to the MTU of 1500 Byte each packet will be split into three ip-packets.
Approximately 1 of 200 Packets were not correctly
reassembled by the Kernel, so they cannot be received within user-space. The
command nstat says, that there are reassembling errors
due to timeout, but at least in wireshark all packets are correctly displayed.
Sometime the kernel issues a icmp-messages, saying that there
was a timeout during ip reassembling.
I fir9st thought that it might be a performance problem, so I increased the
time between the packets to about one packet per 500 ms but without success.
Then I decided to reduce the payload to 1024 Byte, because it might be a buffer
(or TSE FIFO) problem. Now all packets are send into one ipv4 packet and there
is nothing lost on the receiver side, but when I reduced the MTU of the host
from 1500 to 800 byte (each datagram will be split into two packets now) the
problem accurse again!
So this might be a reassembling issue.

-- 
You are receiving this mail because:
You are the assignee for the bug.
