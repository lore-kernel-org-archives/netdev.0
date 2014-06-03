From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 77221] New: Clear tx_flags when transhdrlen == 0 in
 ip_append_data without checking?
Date: Tue, 3 Jun 2014 08:33:06 -0700
Message-ID: <20140603083306.40ff45ee@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:37163 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754815AbaFCPdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 11:33:10 -0400
Received: by mail-pb0-f48.google.com with SMTP id rr13so5624781pbb.35
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2014 08:33:10 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id ko10sm29288792pbd.52.2014.06.03.08.33.08
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 08:33:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue, 3 Jun 2014 00:46:20 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 77221] New: Clear tx_flags when transhdrlen == 0 in ip_append_data without checking?


https://bugzilla.kernel.org/show_bug.cgi?id=77221

            Bug ID: 77221
           Summary: Clear tx_flags when transhdrlen == 0 in ip_append_data
                    without checking?
           Product: Networking
           Version: 2.5
    Kernel Version: 3.14
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: yangzhe1990@gmail.com
        Regression: No

Hi,

While I was tracing why TX_TIMESTAMP won't work with RAW socket and
Non-privileged ICMP socket, I found that both raw.c and ping.c call
ip_append_data with transhdrlen set to 0, and in ip_append_data, there are
timestamp specific 

924                                 else
925                                         /* only the initial fragment is
926                                            time stamped */
927                                         cork->tx_flags = 0;

To my understanding in ping.c transhdrlen should be set to sizeof(struct
icmphdr) just like what icmp.c did.

And for RAW socket, since there are no concept of fragmentation, should we
check the protocol and only set cork->tx_flags = 0 when the socket_type !=
SOCK_RAW

-- 
You are receiving this mail because:
You are the assignee for the bug.
