From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 76791] New: Problem with esp sequence and anti-replay
 window logic.
Date: Fri, 23 May 2014 10:40:45 -0700
Message-ID: <20140523104045.501bba04@samsung-9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:53385 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751186AbaEWRks (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2014 13:40:48 -0400
Received: by mail-pa0-f53.google.com with SMTP id kp14so4358380pab.26
        for <netdev@vger.kernel.org>; Fri, 23 May 2014 10:40:48 -0700 (PDT)
Received: from samsung-9 ([216.9.110.11])
        by mx.google.com with ESMTPSA id zq5sm5608193pbb.37.2014.05.23.10.40.47
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 May 2014 10:40:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 23 May 2014 00:22:53 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 76791] New: Problem with esp sequence and anti-replay window logic.


https://bugzilla.kernel.org/show_bug.cgi?id=76791

            Bug ID: 76791
           Summary: Problem with esp sequence and anti-replay window
                    logic.
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.34
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: bhargav.1226@gmail.com
        Regression: No

Hi,

As the esp sequence number is a 32 bit field in the ESP packet, the maximum
sequence number could be 4294967295 [as 2^32 is 4294967296], then after the
sender will send the esp sequence starting from 1 again.

Lets say a scenario, if there is a huge traffic continously and the esp
sequence number reaches the maximum, and for the next packets the esp sequence
will be 1. 
The highest sequence number received will be 4294967295.

But the anti-replay logic will check the difference of the highest sequence
number  till that time and the sequence number of the received packet. In this
case the difference  will be greater than the replay window size. There is a
chance of dropping of packets.

Seems it is a bug. Do we have to fix the anti-replay window to cycle the
highest sequence like the sender is doing for the esp sequence number?

Thanks,
Bhargav

-- 
You are receiving this mail because:
You are the assignee for the bug.
