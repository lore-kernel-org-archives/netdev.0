From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 195617] New: TCP may send small segments limited to
 initial window size
Date: Sat, 29 Apr 2017 23:01:15 -0700
Message-ID: <20170429230115.6b30ef13@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36850 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S969718AbdD3GBS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 02:01:18 -0400
Received: by mail-pf0-f178.google.com with SMTP id q66so20195689pfi.3
        for <netdev@vger.kernel.org>; Sat, 29 Apr 2017 23:01:18 -0700 (PDT)
Received: from xeon-e3 (76-14-206-252.or.wavecable.com. [76.14.206.252])
        by smtp.gmail.com with ESMTPSA id v85sm19685996pfk.5.2017.04.29.23.01.17
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 29 Apr 2017 23:01:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sun, 30 Apr 2017 00:50:22 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 195617] New: TCP may send small segments limited to initial window size


https://bugzilla.kernel.org/show_bug.cgi?id=195617

            Bug ID: 195617
           Summary: TCP may send small segments limited to initial window
                    size
           Product: Networking
           Version: 2.5
    Kernel Version: 4.9.24
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: stephen@networkplumber.org
          Reporter: ambrop7@gmail.com
        Regression: No

Created attachment 256141
  --> https://bugzilla.kernel.org/attachment.cgi?id=256141&action=edit  
packet trace

I am seeing what I believe is faulty behavior when a Linux client connects to a
TCP/IPv4 server which advertises a very small initial window. After the client
sends a small segment limited to this small window, the server ACKs the data
and extends the window considerably, but the client proceeds to send very small
segments.

Here is a summary of the packets:
- Client: SYN
- Server: SYN,ACK,Win=1
- Client: ACK
- Client: ACK,Data=1B
- Server: ACK,Win=49984
- Client: ACK,Data=47B
- Client: ACK,Data=48B
- Client: ACK,Data=48B
- Client: ACK,Data=48B
...

This example was with initially advertised window (WIN) equal to 1, but
generally it appears that Linux will limit outgoing segments to no more than
max(48,WIN).

I have tested the server with a Windows 10 client which does not have this
problem, the client starts sending fully sized segments when the window is
extended.

-- 
You are receiving this mail because:
You are the assignee for the bug.
