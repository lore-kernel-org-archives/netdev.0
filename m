From: Olaf Kirch <okir@suse.de>
Subject: TIOCSETD with PPP, mkiss, etc
Date: Mon, 10 Jan 2005 14:07:59 +0100
Message-ID: <20050110130759.GA16911@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Wouldn't it be safer if the ldisc open function for PPP, mkiss etc
included a check for CAP_NET_ADMIN privilege, and reject the attempt to
set the line discipline if the user is not privileged? The slip module
already has this check, but other modules don't.

I looked at various protocol modules (ppp sync/async, mkiss, irtty, ...)
and there is no immediate security problem; these modules either do
not allocate a netdevice, or if they do, they check for netif_running()
before they pass the decoded packet to the network layer.

Still I think it's somewhat dangerous to allow a user to open a pty pair,
set the slave's line discipline and feed it whatever he likes.

Olaf
-- 
Olaf Kirch     | Things that make Monday morning interesting, #2:
okir@suse.de   |        "We have 8,000 NFS mount points, why do we keep
---------------+ 	 running out of privileged ports?"
