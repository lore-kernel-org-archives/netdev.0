From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [Bug 8013] New: select for write hangs on a socket after write returned ECONNRESET
Date: Sat, 17 Feb 2007 19:25:33 +0300
Message-ID: <20070217162533.GA22369@2ka.mipt.ru>
References: <20070215160405.3bd30b05@localhost.localdomain> <20070216152557.GA20641@2ka.mipt.ru> <20070216152858.GA22020@2ka.mipt.ru> <20070216153957.GB22020@2ka.mipt.ru> <20070216155450.GC22020@2ka.mipt.ru> <20070216161045.GA2371@2ka.mipt.ru> <20070216102914.7d4b34f0@freekitty> <20070216183426.GA3138@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:40401 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965309AbXBQQZt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Feb 2007 11:25:49 -0500
Content-Disposition: inline
In-Reply-To: <20070216183426.GA3138@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 16, 2007 at 09:34:27PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> Otherwise we can extend select output mask to include hungup too
> (getting into account that hungup is actually output event).

This is another possible way to fix select after write after connection
reset.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/fs/select.c b/fs/select.c
index fe0893a..f2a8e46 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -186,7 +186,7 @@ get_max:
 #define SET(i,m)	(*(m) |= (i))
 
 #define POLLIN_SET (POLLRDNORM | POLLRDBAND | POLLIN | POLLHUP | POLLERR)
-#define POLLOUT_SET (POLLWRBAND | POLLWRNORM | POLLOUT | POLLERR)
+#define POLLOUT_SET (POLLWRBAND | POLLWRNORM | POLLOUT | POLLERR | POLLHUP)
 #define POLLEX_SET (POLLPRI)
 
 int do_select(int n, fd_set_bits *fds, s64 *timeout)

-- 
	Evgeniy Polyakov
