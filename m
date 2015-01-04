From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 89831] New: timeout of TCP-sockets is *infinite* by
 default .. even if TCP-connection is already *broken*
Date: Sat, 3 Jan 2015 17:33:30 -0800
Message-ID: <20150103173330.0f9b209b@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:65062 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493AbbADBdj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jan 2015 20:33:39 -0500
Received: by mail-pa0-f46.google.com with SMTP id lf10so26265183pab.33
        for <netdev@vger.kernel.org>; Sat, 03 Jan 2015 17:33:39 -0800 (PST)
Received: from urahara (static-50-53-82-155.bvtn.or.frontiernet.net. [50.53.82.155])
        by mx.google.com with ESMTPSA id oa8sm50372217pdb.84.2015.01.03.17.33.37
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Jan 2015 17:33:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Tue, 16 Dec 2014 22:33:50 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 89831] New: timeout of TCP-sockets is *infinite* by default .. even if TCP-connection is already *broken*


https://bugzilla.kernel.org/show_bug.cgi?id=89831

            Bug ID: 89831
           Summary: timeout of TCP-sockets is *infinite* by default ..
                    even if TCP-connection is already *broken*
           Product: Networking
           Version: 2.5
    Kernel Version: all
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: IPV4
          Assignee: shemminger@linux-foundation.org
          Reporter: polymorphm@gmail.com
        Regression: No

Created attachment 160881
  --> https://bugzilla.kernel.org/attachment.cgi?id=160881&action=edit
test for catch infinite freezing (on TCP-sockets by default) on GNU/Linux

good day!

please, very sorry me for your time. :-) [and sorry for my bad english].

big problem in that fact: *most* application-programmers think that if
TCP-connection is already *broken* -- that timeout of TCP-socket will *NOT* be
*infinite*. (default system timeout).

I prepared example code:
https://gist.github.com/polymorphm/0e057402c9fa82547d72 (and this file
"to-test.c" -- in attachment).

this example code ("to-test.c") -- shows that if TCP-connection *broken* --
that timeout will *never* be reached (for broken TCP-connection. EVEN AFTER
SOME DAYS).

program "to-test.c" -- becomes to infinite freezing -- after "[step 8]":

        $ gcc -Wall -Werror -o to-test to-test.c && sudo ./to-test
        ***** begin of test *****
        [step 1] creating socket...
        ***** INFO: is used SO_KEEPALIVE by default for TCP-sockets? answer: 0
*****
        [step 2] connecting socket...
        [step 3] time waiting (1s)...
        [step 4] breaking down network...    [wlp1s0]
        # ip link set down dev wlp1s0
        [step 5] time waiting (15s)...
        [step 6] reestablishing up network...    [wlp1s0]
        # ip link set up dev wlp1s0
        [step 7] time waiting (1s)...
        [step 8] waiting of socket timeout (or we are freezed *infinity*?)...

    (infinite freeze -- at this point)


probably, this issue-ticket will be marked as WONTFIX (and again: very sorry me
for your time!). but this issue-ticket -- need at least for official canonical
URL-link for answer to problem of default timeout of *broken* TCP-connection on
GNU/Linux.

when I speek with some application-programmers -- they say me: if GNU/Linux
freeze at broken-TCP-connections (with default settings of socket) than is
*bug* of GNU/Linux. and I maked this issue-ticket. sorry.

-- 
You are receiving this mail because:
You are the assignee for the bug.
