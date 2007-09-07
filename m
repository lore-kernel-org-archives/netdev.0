From: =?UTF-8?Q?P=C3=A1draig_Brady?= <P@draigBrady.com>
Subject: auto recycling of TIME_WAIT connections
Date: Fri, 7 Sep 2007 10:21:45 +0100
Message-ID: <46E11829.4090607@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.parkwest.mxsweep.com ([89.149.149.67]:1276 "EHLO
	smtp1.mxsweep.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965029AbXIGJe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2007 05:34:29 -0400
Content-Class: urn:content-classes:message
Received: from jumpgate ([84.203.137.218] helo=[192.168.2.25]) by yzordderrex.lincor.com with asmtp (Exim 3.35 #1 (Debian)) id 1ITa3T-0007Gl-00 for <netdev@vger.kernel.org>; Fri, 07 Sep 2007 10:23:11 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As I see it, TIME_WAIT state is required for 2 reasons:

  to handle wandering duplicate packets
  (so a reincarnation of a connection will not be corrupted by these pa=
ckets)

  To handle last ack from active closer (client) not being received by =
remote.
  If that happened, the server which is in LAST_ACK state would retrans=
mit its FIN
  (which may contain data also) so the client must be in TIME_WAIT stat=
e to handle that.
  If client is not in TIME_WAIT state, then it could only indicate to t=
he server
  that data was maybe lost (with an RST).

The first issue, requires a large timeout, and
the TIME_WAIT timeout is currently 60 seconds on linux.
That timeout effectively limits the connection rate between
local TCP clients and a server to 32k/60s or around 500 connections/sec=
ond.

But that issue can't really happen when the client
and server are on the same machine can it, and
even if it could, the timeouts involved would be shorter.

Now linux does have an (undocumented) /proc/sys/net/ipv4/tcp_tw_recycle=
 flag
to enable recycling of TIME_WAIT connections. This is global however an=
d could cause
problems in general for external connections.

So how about auto enabling recycling for local connections?

cheers,
P=C3=A1draig.
