From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 83131] New: can: ti_hecc.c: closing device while receiving
 can messages, effectively disables all socket transfer
Date: Mon, 25 Aug 2014 14:45:07 -0700
Message-ID: <20140825144507.09c952cf@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:63184 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753453AbaHYVpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 17:45:11 -0400
Received: by mail-pd0-f180.google.com with SMTP id v10so20791714pde.25
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 14:45:11 -0700 (PDT)
Received: from urahara (static-50-53-65-80.bvtn.or.frontiernet.net. [50.53.65.80])
        by mx.google.com with ESMTPSA id yw4sm763645pbc.69.2014.08.25.14.45.10
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Aug 2014 14:45:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sun, 24 Aug 2014 06:07:49 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 83131] New: can: ti_hecc.c: closing device while receiving can messages, effectively disables all socket transfer


https://bugzilla.kernel.org/show_bug.cgi?id=83131

            Bug ID: 83131
           Summary: can: ti_hecc.c: closing device while receiving can
                    messages, effectively disables all socket transfer
           Product: Networking
           Version: 2.5
    Kernel Version: 3.16.1
          Hardware: All
                OS: Linux
              Tree: PREEMPT_RT
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: jan.sondhauss@gmail.com
        Regression: No

drivers/net/can/ti_hecc.c:

When closing the can device, its not ensured that it gets removed from the
socket-poll list.

The problem here lies in the ti_hecc_rx_poll() function which returns early
when the device is closed already.
This leads to napi_complete() never being called, thus the device stays in the
napi's poll list forever and every task reading from any socket is polling this
device. The system is now basically unreachable.

The patch attached seams to fix this problem by removing the early return in
the ti_hecc_rx_poll function. But I'm not sure whether this is the correct
solution.

-- 
You are receiving this mail because:
You are the assignee for the bug.
