From: Andreas Henriksson <andreas@fatal.se>
Subject: Re: iproute2: git pull request from debian repo.
Date: Fri, 19 Oct 2007 16:48:15 +0200
Message-ID: <20071019144815.GB30444@scream.fatal.se>
References: <20071019122753.GA30078@scream.fatal.se> <20071019130616.GH1362@baikonur.stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: maximilian attems <max@stro.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:55886 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933222AbXJSOwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 10:52:16 -0400
Content-Disposition: inline
In-Reply-To: <20071019130616.GH1362@baikonur.stro.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello maks!

Thanks for your help. I had to tweak the commands a bit to git it working. I
hope I did it right..

On Fri, Oct 19, 2007 at 03:06:16PM +0200, maximilian attems wrote:
> 
> on klibc i'm asked to attach git log -p on a pull request so
> that the patches can be reviewed, please do so too.

git log upstream..patches -p 

>  
> also apprecitated would be the output of
> git log master..patches | git shortlog
> 

git log upstream..patches | git shortlog

I'm using the branching scheme madcoder described here:
http://lists.madduck.net/pipermail/vcs-pkg/2007-October/000021.html

Unfortunately this includes the extra cherry-picked patches from
upstream-repo/master, but I guess we'll just have to cut those out
manually or make sure that we do our submission right after each
upstream release (when we rebase).

Thanks again.

shortlog:
--------------------------------------------------

Daniel Silverstone (1):
      Avoid infinite loop in ip addr flush.

Justin Pryzby (1):
      ss(8) manpage formatting breaks EXAMPLE


git log -p:
--------------------------------------------------

commit 1e9304759ec9f1fd0d80a52cbb7d08decbe8c9a0
Author: Daniel Silverstone <daniel.silverstone@ubuntu.com>
Date:   Fri Oct 19 13:32:24 2007 +0200

    Avoid infinite loop in ip addr flush.
    
    Fix "ip addr flush" the same way "ip neigh flush" was previously fixed,
    by bailing out if the flush hasn't completed after MAX_ROUNDS (10) tries.

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 518d8cd..ff9e318 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -34,6 +34,8 @@
 #include "ll_map.h"
 #include "ip_common.h"
 
+#define MAX_ROUNDS 10
+
 static struct
 {
 	int ifindex;
@@ -667,7 +669,7 @@ int ipaddr_list_or_flush(int argc, char **argv, int flush)
 		filter.flushp = 0;
 		filter.flushe = sizeof(flushb);
 
-		for (;;) {
+		while (round < MAX_ROUNDS) {
 			if (rtnl_wilddump_request(&rth, filter.family, RTM_GETADDR) < 0) {
 				perror("Cannot send dump request");
 				exit(1);
@@ -694,6 +696,8 @@ int ipaddr_list_or_flush(int argc, char **argv, int flush)
 				fflush(stdout);
 			}
 		}
+		fprintf(stderr, "*** Flush remains incomplete after %d rounds. ***\n", MAX_ROUNDS); fflush(stderr);
+		return 1;
 	}
 
 	if (filter.family != AF_PACKET) {

commit 874e14c54be75cfe2ae8b9261eef64194750807b
Author: Justin Pryzby <justinpryzby@users.sourceforge.net>
Date:   Thu Oct 18 16:06:08 2007 +0200

    ss(8) manpage formatting breaks EXAMPLE
    
    Remove not needed quotes around path which breaks manpage formatting.
    Spotted and original patch by Justin Pryzby, fixed by Andreas Henriksson.
    
    http://bugs.debian.org/443071

diff --git a/man/man8/ss.8 b/man/man8/ss.8
index f732319..0c5bf24 100644
--- a/man/man8/ss.8
+++ b/man/man8/ss.8
@@ -107,7 +107,7 @@ Display all UDP sockets.
 .B ss -o state established '( dport = :ssh or sport = :ssh )'
 Display all established ssh connections.
 .TP
-.B ss -x src \"/tmp/.X11-unix/*\"
+.B ss -x src /tmp/.X11-unix/*
 Find all local processes connected to X server.
 .TP
 .B ss -o state fin-wait-1 '( sport = :http or sport = :https )' dst 193.233.7/24


-- 
Regards,
Andreas Henriksson
