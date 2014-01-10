From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 68501] New: llc_fixup_skb considers PDU len including
 ETH_HLEN
Date: Fri, 10 Jan 2014 15:11:56 -0800
Message-ID: <20140110151156.37ae2618@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:59328 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751263AbaAJXL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 18:11:59 -0500
Received: by mail-pa0-f45.google.com with SMTP id ld10so843826pab.32
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 15:11:59 -0800 (PST)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id ns7sm9734520pbc.32.2014.01.10.15.11.58
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 10 Jan 2014 15:11:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Fri, 10 Jan 2014 03:24:59 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 68501] New: llc_fixup_skb considers PDU len including ETH_HLEN


https://bugzilla.kernel.org/show_bug.cgi?id=68501

            Bug ID: 68501
           Summary: llc_fixup_skb considers PDU len including ETH_HLEN
           Product: Networking
           Version: 2.5
    Kernel Version: 3.0.75
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: high
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: vkatabat@gmail.com
        Regression: No

In below snip of code in llc_fixup_skb we calculate pdulen from
eth_hdr(skb)->h_proto which contains total length of packet include ETH_HLEN.

<snip>
119         if (skb->protocol == htons(ETH_P_802_2)) {
120                 __be16 pdulen = eth_hdr(skb)->h_proto;
121                 s32 data_size = ntohs(pdulen) - llc_len;
122 
123                 if (data_size < 0 ||
124                     !pskb_may_pull(skb, data_size))
125                         return 0;

</snip>


Line 121 should be changed to 

121                 s32 data_size = ntohs(pdulen) - llc_len - ETH_HLEN;



Log
---
kernel: pdu len 18432(72), data_size 69
kernel: skb len 55, skb data_len 0

-- 
You are receiving this mail because:
You are the assignee for the bug.
