From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: TCP Connection teardown seems to violate TCP specification
Date: Wed, 14 Aug 2013 21:21:35 +0200
Message-ID: <1376508095.4596.12.camel@nexus>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx-out-1.rwth-aachen.de ([134.130.5.186]:8035 "EHLO
	mx-out-1.rwth-aachen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932928Ab3HNTb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 15:31:27 -0400
Received: from [192.168.0.131] ([unknown] [178.201.100.77])
 by relay-auth-1.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0MRJ00FWOCFYP510@relay-auth-1.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Wed, 14 Aug 2013 21:21:34 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

the TCP specification states that an endpoint has to accept
packets from the other side even after it has half-closed the
connection locally. This does not seem to be the case
under Linux?

For example, when I wget -O /dev/null https://www.verisign.com/
--max-redir 0, the local TCP stack sends an FIN,ACK close to the end.
However, the webserver has more data to send (Encrypted Alert).
Instead of ACKing the packet, the local side sends a RST.
This seems wrong to me.

Regards
 Damian
