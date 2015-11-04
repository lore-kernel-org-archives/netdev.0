From: =?utf-8?Q?Toke_H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>
Subject: Expected behaviour of `tc qdisc replace`?
Date: Wed, 04 Nov 2015 16:34:49 +0100
Message-ID: <87lhadn5gm.fsf@toke.dk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: cake@lists.bufferbloat.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.tohojo.dk ([77.235.48.147]:42810 "EHLO mail2.tohojo.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932323AbbKDPnK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2015 10:43:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I recently noticed that the behaviour of `tc qdisc replace` differs
depending on whether the qdisc being replaced is of the same kind as the
replacement. I.e.:

# tc qdisc del dev eno1 root
# tc qdisc replace dev eno1 root fq_codel target 100ms interval 200ms
# tc qdisc replace dev eno1 root fq_codel target 5ms                 
# tc qdisc
qdisc fq_codel 8007: dev eno1 root refcnt 2 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 200.0ms ecn 
# tc qdisc del dev eno1 root                                         
# tc qdisc replace dev eno1 root fq_codel target 5ms
# tc qdisc                                          
qdisc fq_codel 8008: dev eno1 root refcnt 2 limit 10240p flows 1024 quantum 1514 target 5.0ms interval 100.0ms ecn 

Notice the difference in interval between the two output lines from tc.

Now, according to the tc man page, `tc qdisc replace` "Performs a nearly
atomic remove/add on an existing node id." In which case I would expect
it to *not* retain settings from the previous configuration.

So my question is: is this a bug, or is it expected behaviour? And if
the latter, what is the difference between `tc qdisc replace` and `tc
qdisc change` then supposed to be?

-Toke
