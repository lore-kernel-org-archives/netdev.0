From: Andrew Morton <akpm@osdl.org>
Subject: tcp heisenbug
Date: Fri, 8 Oct 2004 01:41:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041008014151.26e17547.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I just booted my main workstation into 2.6.9-rc3-mm3 (approx).

fetchmail broke.  It's fetching mail from localhost (ssh port-forwarded to
remote servers) and then for some reason it wants to open an SMTP
connection to localhost.  It was failing, some error message about that
SMTP connection.

While I was poking at it, it started to work.  `uptime' said 6 minutes.  So
I'd be suspecting that there's a jiffy wrap bug in TCP-to-localhost
introduced since 2.6.9-rc3.

I rebooted to do more diagnosis and the damn thing worked fine.

I can't see anything suspicious in the post-rc3 net/ diff.  But if anyone
has fiddled with time-related things in networking, please double-check
your work?
