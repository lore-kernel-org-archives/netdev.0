From: "Radko Mihal" <rmihal@pobox.sk>
Subject: Setting TCP_NODELAY doesn't disable Nagle's alg. on loopback
Date: Tue, 16 May 2006 10:50:30 +0200
Message-ID: <fc1d209cf91d41b5a5ff491732e52283@pobox.sk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1250
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from jahoda.mail-atlas.net ([212.47.13.142]:13330 "EHLO
	jahoda.mail-atlas.net") by vger.kernel.org with ESMTP
	id S1750716AbWEPIvL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 May 2006 04:51:11 -0400
Received: from jahoda ([127.0.0.1])
	by jahoda.mail-atlas.net
	for netdev@vger.kernel.org;
	Tue, 16 May 2006 10:50:30 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

We are facing strange problem with disabling the Nagle's algorithm via setting the TCP_NODELAY flag on server socket (setsockopt), where server is communication with client via loopback.
After the first segment (of the response) is sent by server side, server is waiting for ACK instead of continuing sending next segments (as it should use sliding window principle). The client sends ACK after 40 ms, only then server sends the rest of responses packed into one segment. The 40 ms is a big delay and causes reponse processing to be 10 times slower.

The thing doesn't happen, if we move client to another host. In that case the server don't wait for ACK, don't pack responses and also response processing is much faster.

It seems, like on loopback the Nagle's alg. is still acting (citate from alg. description says:"a first segment is sent immediately, while further data on the sender side is buffered until either a full maximum segment can be sent or an acknowledgement for the first segment is received)

I found some descriptions of the same problem, but with no solution!
Is there a bug in setsockopt()? We are using 2.6.5 kernel.

Regards,
Mihal




