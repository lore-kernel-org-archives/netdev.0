From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 196839] New: use_time of IPsec policy is updated even when
 receiving error packets.
Date: Wed, 6 Sep 2017 08:38:33 -0700
Message-ID: <20170906083833.0dcab8a6@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:38286 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932823AbdIFPil (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 11:38:41 -0400
Received: by mail-pg0-f52.google.com with SMTP id v66so15757022pgb.5
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 08:38:41 -0700 (PDT)
Received: from xeon-e3 (76-14-207-240.or.wavecable.com. [76.14.207.240])
        by smtp.gmail.com with ESMTPSA id j9sm171325pgc.11.2017.09.06.08.38.40
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Sep 2017 08:38:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 06 Sep 2017 10:18:33 +0000
From: bugzilla-daemon@bugzilla.kernel.org
To: stephen@networkplumber.org
Subject: [Bug 196839] New: use_time of IPsec policy is updated even when receiving error packets.


https://bugzilla.kernel.org/show_bug.cgi?id=196839

            Bug ID: 196839
           Summary: use_time of IPsec policy is updated even when
                    receiving error packets.
           Product: Networking
           Version: 2.5
    Kernel Version: 4.8.0
          Hardware: Intel
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: stephen@networkplumber.org
          Reporter: cchenme@gmail.com
        Regression: No

Normally the use_time of policy in SPD is updated if the policy is matched by
incoming or outgoing IP packets. For protect policy, it is updated if ESP/AH
packets are sent or received.

The use_time of SPD_IN policy used by IKE implementation like strongSwan to
check whether there is inbound traffic, thus determine whether it is necessary
to send DPD(dead peer detection, rfc3706) request to check liveness of IPsec
peer.

In case an unprotected packet is received but matches the IPsec SPD IN protect
policy, the packet will be discarded and the error counter XfrmInTmplMismatch
in /proc/net/xfrm_stat is incremented.

But in such error/malicious case, the use_time of SPD IN policy is also
updated. This cause strongSwan to mistakenly regard that the policy is in use
and not to trigger DPD request even when it should.

In short, this is a security hole in kernel and could lead to DoS attack on
IPsec gateway running on Linux.

-- 
You are receiving this mail because:
You are the assignee for the bug.
