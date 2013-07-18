From: Fabian Bergmark <fabian.bergmark@gmail.com>
Subject: Fwd: UDP encapsulation of SCTP packages
Date: Thu, 18 Jul 2013 21:05:48 +0200
Message-ID: <CAG=SMqaMPTTvOHBwiCy17+gOxsBpabkmvG1sEBhf7nus4amuFQ@mail.gmail.com>
References: <CAG=SMqaUdvB_ducuzbcFE0XtjP7vdi5ZRSB8mrua3yuZebbN+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=20cf301b613be46cc004e1cde583
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:44918 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933317Ab3GRTFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 15:05:48 -0400
Received: by mail-ie0-f170.google.com with SMTP id e11so7928899iej.1
        for <netdev@vger.kernel.org>; Thu, 18 Jul 2013 12:05:48 -0700 (PDT)
In-Reply-To: <CAG=SMqaUdvB_ducuzbcFE0XtjP7vdi5ZRSB8mrua3yuZebbN+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--20cf301b613be46cc004e1cde583
Content-Type: text/plain; charset=ISO-8859-1

Im working on implementing UDP encapsulation of SCTP packages.

I have tried to implement  the encapsulation/decapsulation in a way
that is transparent to the logic of the current implementation.

Currently I'am able to send and recieve data over localhost or over
intranet. However, when trying to communicate over NAT I ran in to
problems. Because of port remapping of the UDP source port I included
as a final step to update the source port of the SCTP header and
recalculate the checksum.

This however, causes a kernel panic somewhere between receiving the
UDP packet and replying the INIT_ACK, that I am unable to understand.
Is there anything, besides the source port and checksum in the SCTP
header that needs to be updated?

I have included a packet capture of the INIT-packages that causes the panic.

As I am new to kernel development, general advice on how to debug this
issue is appreciated.

-- Fabian Bergmark

--20cf301b613be46cc004e1cde583
Content-Type: application/octet-stream; name="SCTP in UDP.pcap"
Content-Disposition: attachment; filename="SCTP in UDP.pcap"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_hjab8sgm0

Cg0NCmgAAABNPCsaAQAAAP//////////AwAQAExpbnV4IDMuOS4yLUFSQ0gEAC0ARHVtcGNhcCAx
LjEwLjAgKFNWTiBSZXYgVW5rbm93biBmcm9tIHVua25vd24pAAAAAAAAAGgAAAABAAAARAAAAAEA
AAD//wAAAgAEAGV0aDAJAAEABgAAAAsABAAAdWRwDAAQAExpbnV4IDMuOS4yLUFSQ0gAAAAARAAA
AAYAAAB8AAAAAAAAAM3hBACn17keWgAAAFoAAABSVADWNxQIACfYt8kIAEUCAEwAAEAAQBF3d1Ox
p1fAqAd30tEFOAA4tHzS0QU5AAAAAHTqW3sBAAAk8jfPSgABoAAAAgACjfjWmQAMAAYABQAAgAAA
BMAAAAQAAHwAAAAGAAAAfAAAAAAAAADN4QQAS6LnHloAAABaAAAAUlQA1jcUCAAn2LfJCABFAgBM
AABAAEARd3dTsadXwKgHd9LRBTgAOLR80tEFOQAAAAB06lt7AQAAJPI3z0oAAaAAAAIAAo341pkA
DAAGAAUAAIAAAATAAAAEAAB8AAAABQAAAGwAAAAAAAAAzeEEAGMAmR8BABwAQ291bnRlcnMgcHJv
dmlkZWQgYnkgZHVtcGNhcAIACADN4QQA4LhsHgMACADN4QQAmf+YHwQACAAHAAAAAAAAAAUACAAA
AAAAAAAAAAAAAABsAAAA
--20cf301b613be46cc004e1cde583--
