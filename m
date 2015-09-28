From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 105091] New: ICMP unreachable is not sent when receiving
 GRE packets on device that has no tunnel interface
Date: Sun, 27 Sep 2015 18:06:14 -0700
Message-ID: <20150927180614.52ac9154@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34912 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753807AbbI1BGK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Sep 2015 21:06:10 -0400
Received: by pacfv12 with SMTP id fv12so161034535pac.2
        for <netdev@vger.kernel.org>; Sun, 27 Sep 2015 18:06:10 -0700 (PDT)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by smtp.gmail.com with ESMTPSA id u1sm15769645pbz.56.2015.09.27.18.06.09
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Sep 2015 18:06:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Sun, 27 Sep 2015 22:42:34 +0000
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "shemminger@linux-foundation.org" <shemminger@linux-foundation.org>
Subject: [Bug 105091] New: ICMP unreachable is not sent when receiving GRE packets on device that has no tunnel interface


https://bugzilla.kernel.org/show_bug.cgi?id=105091

            Bug ID: 105091
           Summary: ICMP unreachable is not sent when receiving GRE
                    packets on device that has no tunnel interface
           Product: Networking
           Version: 2.5
    Kernel Version: 4.2
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: low
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: isaac.lee@alliedtelesis.co.nz
        Regression: No

Created attachment 188691
  --> https://bugzilla.kernel.org/attachment.cgi?id=188691&action=edit
fix patch

This used to work in version 3.9. In file ip_gre.c, when a GRE packet is
received and tunnel lookup returned NULL (ie, no such interface), ipgre_rcv()
calls icmp_send() to respond with port unreachable message.

In the latest version, gre_demux.c tries to do the same thing in
gre_cisco_rcv(), but icmp_send fails because skb dst entry has been dropped
(during parse_gre_header() -> iptunnel_pull_header() ->  skb_dst_drop(skb);)
prior to calling icmp_send, causing icmp_send to return early due to rt is
NULL.

A fix patch is attached.

-- 
You are receiving this mail because:
You are the assignee for the bug.
