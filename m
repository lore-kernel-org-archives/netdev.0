From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 106351] New: error in upstream commit
 41fc014332d91ee90c32840bf161f9685b7fbf2b fib_rules:...
Date: Wed, 21 Oct 2015 09:02:46 -0700
Message-ID: <20151021090246.11afdf26@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:36486 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754628AbbJUQCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 12:02:36 -0400
Received: by pacfv9 with SMTP id fv9so60956774pac.3
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2015 09:02:36 -0700 (PDT)
Received: from xeon-e3 (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by smtp.gmail.com with ESMTPSA id pk2sm9893723pbb.21.2015.10.21.09.02.35
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 09:02:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue, 20 Oct 2015 12:20:39 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 106351] New: error in upstream commit 41fc014332d91ee90c32840bf161f9685b7fbf2b fib_rules:...


https://bugzilla.kernel.org/show_bug.cgi?id=106351

            Bug ID: 106351
           Summary: error in upstream commit
                    41fc014332d91ee90c32840bf161f9685b7fbf2b fib_rules:...
           Product: Networking
           Version: 2.5
    Kernel Version: 3.14
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: m.koenigshaus@wut.de
        Regression: No

Hi,
upstream commit 41fc014332d91ee90c32840bf161f9685b7fbf2b has a small flaw.
Before the patch, the loop in dump_rules (line 627 - 638, fib_rules.c) was
canceled if fib_nl_fill_rule returns a value less than zero, after the patch it
is canceled if fib_nl_fill_rule returns a nonzero value. But without errors
fib_nl_fill_rule will return skb-> len. So I thing the termination condition
should be "if (err < 0) break;" not "if (err) break;".
This error leads to OOM - Exceptions in our system with program "ip"! After
changing the code to "if (err < 0) break;" everything works fine.


Regards, Markus

-- 
You are receiving this mail because:
You are the assignee for the bug.
