From: Felix von Leitner <felix-kernel@fefe.de>
Subject: ipv4-mapped ipv4 connect() for UDP broken in test10
Date: Wed, 26 Nov 2003 09:17:45 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031126081745.GA31415__9556.53336500308$1069836659@codeblau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
Resent-Message-Id: <20031126.175018.52712920.yoshfuji@wide.ad.jp>
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

My IPv6 port for djbdns' dnscache does not work with -test10.

The symptom is that all queries time out.

Some digging reveals that djbdns does this (with scope_id 0):

  socket(PF_INET6,...)
  bind socket to ::
  connect() socket to IP of peer (in this case, 210.81.13.179)
  send() dns query

at this point, the query is not sent over ppp0 as it should, but it is
sent to lo.  Not only that, but the queries are _received_ by the same
djbdns (with servfail), although the destination IP is as said above
210.81.13.179 and none of my local IPs: 10.0.0.6, 127.0.0.1, or
217.88.123.45.

Any ideas?  Please do not ship 2.6.0-final with a bug like this in it!

Felix
