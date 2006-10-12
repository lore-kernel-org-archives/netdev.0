From: "Martin Schiller" <mschiller@tdt.de>
Subject: Suppress / delay SYN-ACK
Date: Thu, 12 Oct 2006 10:08:53 +0200
Message-ID: <000101c6edd5$a880d430$1a04010a@V505CP>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.tdt.de ([195.243.126.82]:30886 "EHLO ns.tdt.de")
	by vger.kernel.org with ESMTP id S932512AbWJLIIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2006 04:08:51 -0400
Received: from ns (root@localhost)
	by ns.tdt.de (8.11.6/8.11.6/SuSE Linux 0.5) with SMTP id k9C88oc02850
	for <netdev@vger.kernel.org>; Thu, 12 Oct 2006 10:08:50 +0200
Received: from V505CP (mschiller2 [10.1.4.26])
	by ns.tdt.de (8.11.6/8.11.6/SuSE Linux 0.5) with ESMTP id k9C88ot02843
	for <netdev@vger.kernel.org>; Thu, 12 Oct 2006 10:08:50 +0200
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

I'm searching for a solution to suppress / delay the SYN-ACK packet of a
listening server (-application) until he has decided (e.g. analysed the
requesting ip-address or checked if the corresponding other end of a
connection is available) if he wants to accept the connect request of the
client. If not, it should be possible to reject the connect request.

My idea is to add two ioctl's:
	- One to set the listening socket into "delay_synack" mode.
	- And one to send the synack packet, if the connection should be
accepted.

If the "delay_synack" mode is not enabled, the connection should just work
as usual.

I had a look at the tcp/ipv4 stack for a while and have found out, that this
three-way-handshake is already done before anything comes up to user-space
when I am doing a call to accept(). So I think it wouldn't be possible to
add this feature with "a little hack".

Does anybody have any hints for me where I should start to work?

Regards,
Martin Schiller


