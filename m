From: Andy Lutomirski <luto@amacapital.net>
Subject: SO_TIMESTAMP on tcp sockets?
Date: Mon, 7 May 2012 18:39:48 -0700
Message-ID: <CALCETrVUjLz63uzr+UTf-G1jq9QDcX6Gf9D6AWK8_GmunsJGnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:50666 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756623Ab2EHBkJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2012 21:40:09 -0400
Received: by dady13 with SMTP id y13so1984294dad.19
        for <netdev@vger.kernel.org>; Mon, 07 May 2012 18:40:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been using SO_TIMESTAMPNS to good effect on udp sockets.  I'd
like to do the same thing for tcp.  I realize that this is
semantically strange [1], but I don't think there's a real issue for
my use case.  We have very thin streams -- we are likely to process
each incoming segment as it is received, and I want the most precise
timestamp possible on each segment.

A simple approach (I think) would be for a recvmsg on a tcp socket
with SO_TIMESTAMP(NS) to return at most one skb worth of data along
with the timestamp associated with that skb.  This could be a little
strange if multiple segments overlap or if lro is involved, but
neither of those cases seems like a major problem.

Is there any interest in something like this?

Thanks,
Andy

[1] http://comments.gmane.org/gmane.linux.network/159574
