From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 57851] New: a mistake about macro definition of
 FIB_TABLE_HASHSZ
Date: Fri, 10 May 2013 08:18:54 -0700
Message-ID: <20130510081854.0c6b95ff@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:56452 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752957Ab3EJPS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 May 2013 11:18:59 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so2832500pbc.7
        for <netdev@vger.kernel.org>; Fri, 10 May 2013 08:18:59 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-71-109.bvtn.or.frontiernet.net. [50.53.71.109])
        by mx.google.com with ESMTPSA id ag4sm3072924pbc.20.2013.05.10.08.18.57
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 08:18:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't know if this already made it to netdev. Google SMTP had been
flaky and didn't take it yesterday.


Subject: [Bug 57851] New: a mistake about macro definition of FIB_TABLE_HASHSZ


https://bugzilla.kernel.org/show_bug.cgi?id=57851

           Summary: a mistake about macro definition of FIB_TABLE_HASHSZ
           Product: Networking
           Version: 2.5
    Kernel Version: 3.5
          Platform: All
        OS/Version: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
        AssignedTo: shemminger@linux-foundation.org
        ReportedBy: nosongyang@gmail.com
        Regression: No


#ifdef CONFIG_IP_ROUTE_MULTIPATH

#define FIB_RES_NH(res)          ((res).fi->fib_nh[(res).nh_sel])

#define FIB_TABLE_HASHSZ 2

#else /* CONFIG_IP_ROUTE_MULTIPATH */

#define FIB_RES_NH(res)          ((res).fi->fib_nh[0])

#define FIB_TABLE_HASHSZ 256

#endif /* CONFIG_IP_ROUTE_MULTIPATH */

There is a confuse macro definition about the FIB_TABLE_HASHSZ. This mistake
can generate an error, but will affect performance.

-- 
Configure bugmail: https://bugzilla.kernel.org/userprefs.cgi?tab=email
------- You are receiving this mail because: -------
You are the assignee for the bug.
