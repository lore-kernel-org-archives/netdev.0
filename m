From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 59971] New: tcp_info::tcpi_last_ack_recv = 0xFFFFFFF6
Date: Thu, 20 Jun 2013 08:24:25 -0700
Message-ID: <20130620082425.3bb6266a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:43021 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757957Ab3FTPY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 11:24:29 -0400
Received: by mail-pa0-f45.google.com with SMTP id bi5so6428753pad.32
        for <netdev@vger.kernel.org>; Thu, 20 Jun 2013 08:24:29 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-71-109.bvtn.or.frontiernet.net. [50.53.71.109])
        by mx.google.com with ESMTPSA id re16sm1206377pac.16.2013.06.20.08.24.27
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 20 Jun 2013 08:24:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 20 Jun 2013 04:20:40 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 59971] New: tcp_info::tcpi_last_ack_recv = 0xFFFFFFF6


https://bugzilla.kernel.org/show_bug.cgi?id=59971

           Summary: tcp_info::tcpi_last_ack_recv = 0xFFFFFFF6
           Product: Networking
           Version: 2.5
    Kernel Version: 2.6.37
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: Other
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: _kobold@ukr.net
        Regression: No


tcp_info::tcpi_last_ack_recv becomes "negative" sometimes. -10 msec or 1 jiffy
in my case. Probably due to lack of synchronization in the kernel.

struct tcp_info tinfo = {0};
socklen_t len = sizeof(tinfo);
if (getsockopt(thesocket, SOL_TCP, TCP_INFO, (void*)&tinfo, &len) == 0)
    printf("%u\n", tinfo.tcpi_last_ack_recv);

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
