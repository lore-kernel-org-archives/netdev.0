From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 196533] New: kernel stack infoleaks
Date: Sun, 30 Jul 2017 11:03:22 -0700
Message-ID: <20170730110322.2f8171ea@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:36873 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754232AbdG3SDZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 14:03:25 -0400
Received: by mail-pg0-f41.google.com with SMTP id y129so129512540pgy.4
        for <netdev@vger.kernel.org>; Sun, 30 Jul 2017 11:03:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sun, 30 Jul 2017 05:13:08 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 196533] New: kernel stack infoleaks


https://bugzilla.kernel.org/show_bug.cgi?id=196533

            Bug ID: 196533
           Summary: kernel stack infoleaks
           Product: Networking
           Version: 2.5
    Kernel Version: 4.12.2
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: stephen@networkplumber.org
          Reporter: sohu0106@126.com
        Regression: No

bug in net/irda/af_irda.c  


Sometimes irda_getsockopt() doesn't initialize all members of list field of
irda_device_list struct.  This structure is then copied to
userland.  It leads to leaking of contents of kernel stack memory.  We have to
initialize them to zero , or it will allows local users to obtain potentially
sensitive information from kernel stack memory by reading a copy of this
structure  



https://github.com/torvalds/linux/pull/440

-- 
You are receiving this mail because:
You are the assignee for the bug.
