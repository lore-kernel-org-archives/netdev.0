From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 68011] New: spin_unlock is missed in function
 (netpoll_send_skb_on_dev) in file (linux-3.12/net/core/netpoll.c)
Date: Wed, 1 Jan 2014 21:52:31 -0800
Message-ID: <20140101215231.50ea361e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:51701 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbaABFwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 00:52:39 -0500
Received: by mail-pd0-f180.google.com with SMTP id q10so13806479pdj.39
        for <netdev@vger.kernel.org>; Wed, 01 Jan 2014 21:52:39 -0800 (PST)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id hz10sm98923432pbc.36.2014.01.01.21.52.38
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 01 Jan 2014 21:52:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 1 Jan 2014 11:52:20 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 68011] New: spin_unlock is missed in function (netpoll_send_skb_on_dev) in file (linux-3.12/net/core/netpoll.c)


https://bugzilla.kernel.org/show_bug.cgi?id=68011

            Bug ID: 68011
           Summary: spin_unlock is missed in function
                    (netpoll_send_skb_on_dev) in file
                    (linux-3.12/net/core/netpoll.c)
           Product: Networking
           Version: 2.5
    Kernel Version: 3.12
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: atamrawi@iastate.edu
        Regression: No

In function (netpoll_send_skb_on_dev) in file (linux-3.12/net/core/netpoll.c):

The structure (txq->_xmit_lock) gets successfully locked at line (383) by
(__netif_tx_trylock(txq)) and unlocked by (__netif_tx_unlock(txq)) at line
(398).

The problem occurs when the loop breaks at line (390) and the structure
(txq->_xmit_lock) still locked. In that case, the structure (txq->_xmit_lock)
never gets unlocked.

A possible solution is to call (__netif_tx_unlock(txq)) before the break at
line (390)

-- 
You are receiving this mail because:
You are the assignee for the bug.
