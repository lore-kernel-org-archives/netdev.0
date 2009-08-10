From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v8)
Date: Mon, 10 Aug 2009 14:06:47 -0700
Message-ID: <87fxbz5qfs.fsf@caffeine.danplanet.com>
References: <1249918379-29414-1-git-send-email-danms@us.ibm.com>
	<1249918379-29414-6-git-send-email-danms@us.ibm.com>
	<20090810210235.GB24373@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: "Serge E. Hallyn" <serue@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:49167 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753712AbZHJVG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 17:06:57 -0400
In-Reply-To: <20090810210235.GB24373@us.ibm.com> (Serge E. Hallyn's message of "Mon\, 10 Aug 2009 16\:02\:35 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SH> Thanks, Dan.  Apart from the double-free on error case in
SH> sock_copy_buffers(), this looks very good to me.  So with that
SH> change, please feel free to add:

Okay, thanks, I've got that fixed up now.

SH> Dan, do you have any testcases (even just descriptions of how to
SH> test, which i'll then try to script) i can add to cr_tests?

Yeah, I've got a big ugly test program that I've rolled automatic
tests for most scenarios into.  Here's the usage output of the test.
I'll get it cleaned up and posted too:

  Usage: ./testprog [-t (s|d)] [-wn] TEST
  Where:
    -t s, -t d:             Select STREAM or DGRAM sockets
    -w:                     Wait for a response before restarting
    -n:                     Don't terminate the test on successful restart
  
  Where TEST is one of:
    --unix_pair:            Pair of sockets using socketpair()
    --unix_unlinked:        Listen socket with an unlinked path
    --unix_pair_path:       Pair of sockets using paths
    --unix_pair_abstract:   Pair of sockets using abstract names
    --unix_inflight:        Pair of sockets with data in flight
    --unix_inflight_closed: Pair of sockets, one side closed after preflight
    --unix_midaccept:       Listen socket with unaccepted peer
    --unix_fdpass:          Attempt to pass an FD
    --unix_passcred:        Attempt to pass credentials
    --unix_path:            Post-restart path-based connect to listen socket
    --unix_abstract:        Post-restart abstract connect to listen socket
    --unix_path_unlink:     Like pair_path, but unlink socket before restart
    --unix_deadpeer:        Close peer socket with data in flight
    --unix_testopt:         Unix socket setting and testing for a sockopt
    --unix_anoninflight:    Inflight data with unconnected DGRAM sockets
    --inet_connected:       Pair of localhost INET4 sockets
    --inet6_connected:      Pair of localhost INET6 sockets
    --nonet:                No network, just a simple loop
    --sendmail:             Try to start up sendmail and checkpoint it

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
