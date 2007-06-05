From: chris schlund <chrisschlund@gmx.de>
Subject: Socket hangs in read() when putting interface down
Date: Tue, 05 Jun 2007 17:11:29 +0200
Message-ID: <46657D21.3010203@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:37796 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932857AbXFEPA0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jun 2007 11:00:26 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using read() on a socket(AF_INET, SOCK_STREAM) connected via any network
interface (e.g eth0) and putting this interface down (ifconfig) while
the socket is in read() produces a hanger (the read() will not return
anymore).
Even if I install sigaction signal handler I got no signal when the
interface is removed.

This may be ok on a major interface like eth0 but it is a problem when
using a ppp interface via GSM data or GPRS connection.
Killing the pppd while the socket waits in read() produces the same
behaviour. Also a broken connection looks the same.
It is reproducable on several 2.6 kernel versions including the lastest
stable 2.6.21.

On my understanding "ifconfig down" should lead into a read() error.

Unfortunately I am not very familiar with in-depth kernel programming
and I am still wondering about the magic inside the kernel:

ifconfig -> net/dev.c:dev_close() notifies a call chain which probably
could/should handle this.
But I miss the dependency to net/ipv4/tcp.c: tcp_recvmsg() function.
This is where I think my receive is blocking.

Can someone give me a hint where to look?

Thanks and kind regards
Chris


p.s.
This happens only, when socket is in blocking mode.
I am using a simple example like:
s = socket();
connect(s);
while(){
  read(s)
}


