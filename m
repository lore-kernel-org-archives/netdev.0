From: =?ISO-8859-1?Q?David_T=E4ht?= <dave.taht@gmail.com>
Subject: Asserting ECN from userspace?
Date: Tue, 04 Oct 2011 23:18:26 -0700
Message-ID: <4E8BF6B2.6030101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, bloat-devel@lists.bufferbloat.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:64828 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935693Ab1JFJd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 05:33:26 -0400
Received: by bkbzt4 with SMTP id zt4so3209487bkb.19
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2011 02:33:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


No sooner had I noted (with pleasure) the kernel's new ability to
correctly set the dscp bits on IPv6 TCP streams without messing with the
negotiated ECN status, that I found several use cases where being able
to assert ECN from userspace (for either ipv4, or ipv6) would be useful.

1) Applications such as bittorrent (transmission, etc) that are much
more aware of their overall environment could assert ECN on their UDP
streams to indicate congestion.

2) Test tools. It would be nice to be able, from userspace, to easily
diagnose if ECN was working on a stream, end to end, and being able to
set and receive the ECN bits on a less algorithmic basis (ie, not wedged
deep within a kernel aqm such as RED or SFB)

3) Web Proxies. A web proxy could note when it was experiencing
congestion on one side of the proxied connection (or another) and signal
the other side to slow down.

Ah, ECN, we hardly know ye.

as for item 1 I'm hard pressed to think of a case where setting the ECN
bits on udp streams would introduce a security problem.

As for 2, can live without.

As for 3... perhaps a grantable network capability? A proxy could
acquire privs to twiddle those bits before dropping root privs.

That begs the question of how to see those bits in the first place. OOB
data?

And twiddling them, on a per stream basis, for a single packet, would
seem to require something more robust than setsockopt/getsockopt
(although that would work for udp streams)
