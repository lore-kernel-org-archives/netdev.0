From: Stephen Hemminger <shemminger@osdl.org>
Subject: TCP congestion graphs
Date: Wed, 25 Oct 2006 11:02:07 -0700
Message-ID: <20061025110207.78d38779@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:54222 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964773AbWJYWMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 18:12:06 -0400
To: Douglas Leith <doug.leith@nuim.ie>, Sangtae Ha <sha2@ncsu.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I ran some congestion window tests against 2.6.19-rc3.
For congestion window graphs see:
	http://developer.osdl.org/shemminger/tcp/2.6.19-rc3/

The connection was a single flow with a 500ms RTT and a 
100Mbit slowest link speed.

BIC  			OK
CUBIC 			OK (after patch)
HIGHSPEED		BROKEN?
HTCP			OK
RENO			OK (massive overshoot)
SCALEABLE		OK
VEGAS			OK (no better than Reno)
VENO			Same as Reno?
WESTWOOD		Overshoot then low window

Highspeed has something wrong (test glitch?)
Westwood behaves poorly
Veno seems no better than either Reno or Vegas in this
case.

The end systems were from latest git. The netem bridge is using
2.6.18-rt with a patch to netem to use hrtimers.  iperf was modified
to allow easy selection of congestion control.

-- 
Stephen Hemminger <shemminger@osdl.org>
