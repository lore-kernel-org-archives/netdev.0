From: Alan Stern <stern@rowland.harvard.edu>
Subject: Problem with VPN: can't send NAT-T keepalives
Date: Mon, 10 Mar 2014 16:08:33 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1403101554080.1771-100000@netrider.rowland.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netrider.rowland.org ([192.131.102.5]:39540 "HELO
	netrider.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752409AbaCJUIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 16:08:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The VPN setup on my laptop computer doesn't work.  The most recent
tests have been with the 3.14-rc6 kernel, using libreswan under Fedora
20.

The secure channel apparently gets set up correctly, but it gets torn 
down again after three keepalive packets fail.  The error messages from 
the "pluto" program look like this:

Mar 10 15:03:40 saphir.localdomain pluto[11361]: ERROR: "nm-ipsec-l2tpd-11265" #1: sendto on wlan0 on XX.XX.XX.XX:4500 failed in NAT-T Keep Alive. Errno 105: No buffer space available
Mar 10 15:04:20 saphir.localdomain pluto[11361]: ERROR: "nm-ipsec-l2tpd-11265" #1: sendto on wlan0 to XX.XX.Xx.XX:4500 failed in NAT-T Keep Alive. Errno 105: No buffer space available

(the destination IP addresses have been anonymized).  I checked the
userspace source; these error codes are nothing more than the value of
errno following a failed sendto system call.

tcpdump shows that keepalive packets are received at 20-second
intervals, as expected, but none are sent.  However, after the
encrypted tunnel is torn down, several keepalive packets get sent in
quick succession, as though some queue was draining.  Of course, by
then it is far too late.

The same problem occurs over a wired Ethernet connection and a wireless 
link, so it appears to be higher up in the networking stack, not in the 
device driver.

Can anyone help fix this problem?

Alan Stern
