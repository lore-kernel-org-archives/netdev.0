From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 85091] New: neighbour table overflow is not reported and
 impacts localhost TCP connectivity
Date: Wed, 24 Sep 2014 09:32:16 -0700
Message-ID: <20140924093216.083c77b4@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:41717 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751875AbaIXQcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 12:32:25 -0400
Received: by mail-pd0-f174.google.com with SMTP id g10so8318977pdj.5
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 09:32:25 -0700 (PDT)
Received: from urahara (static-50-53-65-80.bvtn.or.frontiernet.net. [50.53.65.80])
        by mx.google.com with ESMTPSA id fk11sm15189661pdb.91.2014.09.24.09.32.23
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Sep 2014 09:32:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Wed, 24 Sep 2014 03:44:41 -0700
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 85091] New: neighbour table overflow is not reported and impacts localhost TCP connectivity


https://bugzilla.kernel.org/show_bug.cgi?id=85091

            Bug ID: 85091
           Summary: neighbour table overflow is not reported and impacts
                    localhost TCP connectivity
           Product: Networking
           Version: 2.5
    Kernel Version: 3.8 - 3.17-rc6
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: aschultz@tpip.net
        Regression: No

With the default gc_thresh values and a busy /16 network attached, the
neighbour cache can overflow. No indication is given that this happens and it
does impact TCP on localhost.

Test setup:

* about 16k (simulated IP/MAC's) on one interface
* web server behind on second interface
* routing between the two
* HTTP benchmark from the 16k IP's to the web server
* for localhost connectivity verification a netperf instance is run on
localhost like so: 'netperf -D 1 -l 600 127.0.0.1'

Result:

Kernel has to learn the 16k IP/MAC combinations, as soon as gc_thresh3 is hit,
netperf stalls, no syslog/kernel message indicates the problem.

The only indication are log entries like this:

  "net_ratelimit: 1464 callbacks suppressed"

No other messages are logged.

-- 
You are receiving this mail because:
You are the assignee for the bug.
