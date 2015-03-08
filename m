From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 94501] New: Kernel crash while deleting a nftables "table"
Date: Sun, 8 Mar 2015 09:30:40 -0700
Message-ID: <20150308093040.0c3f7c41@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:44889 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752582AbbCHQao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2015 12:30:44 -0400
Received: by padet14 with SMTP id et14so42373593pad.11
        for <netdev@vger.kernel.org>; Sun, 08 Mar 2015 09:30:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sun, 8 Mar 2015 12:45:39 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 94501] New: Kernel crash while deleting a nftables "table"


https://bugzilla.kernel.org/show_bug.cgi?id=94501

            Bug ID: 94501
           Summary: Kernel crash while deleting a nftables "table"
           Product: Networking
           Version: 2.5
    Kernel Version: 4.0.0-rc2
          Hardware: x86-64
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: jp.pozzi@izzop.net
        Regression: No

Created attachment 169681
  --> https://bugzilla.kernel.org/attachment.cgi?id=169681&action=edit
Table after execution script

Hello,

I am testing "nftables" and get a kernel crash while deleting a table.
The first problem arose when I try to "flush" a table before executing a script
file :
ENTREE.dat:5:1-2: Error: Could not process rule: File exists
table ip NIV_UN {
^^
ENTREE.dat:5:1-2: Error: Could not process rule: File exists
table ip NIV_UN {
^^
The script begins with :
flush table NIV_UN;

table ip NIV_UN {
set PORT_TCP_IN { 
        type inet_service
include "xxxxx.set"
    }
............

If I "manually" flush the table with "nft flush table NIV_UN" all is good and
the content of the table is flushed, but remains in a state where no modify is
possible.
The command "nft flush table NIV_UN" works and the result seems OK (cf FILE 1),
but if I try to re-execute the script I get the same error.
If I try to delete the table with "nft delete table NIV_UN" I get a kernel
crash which is not visible in the logs, the only way I found is to take a photo
of the screen ...

Files attached : NFTLIST.txt : right after execution
                 NFTLIST_FLUSH.txt : after execution a "flush"
                 screen_img.jpg

-- 
You are receiving this mail because:
You are the assignee for the bug.
