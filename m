From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH net-next 00/20] Delete more semi-useless stuff from
 TIPC.
Date: Sat, 1 Jan 2011 17:53:31 -0500
Message-ID: <20110101225330.GF30150@windriver.com>
References: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
 <20110101.135952.226766850.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:54430 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176Ab1AAWxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jan 2011 17:53:34 -0500
Content-Disposition: inline
In-Reply-To: <20110101.135952.226766850.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Re: [PATCH net-next 00/20] Delete more semi-useless stuff from TIPC.] On 01/01/2011 (Sat 13:59) David Miller wrote:

> From: Paul Gortmaker <paul.gortmaker@windriver.com>
> Date: Fri, 31 Dec 2010 23:59:15 -0500
> 
> > There really isn't a lot to see here technically.  There is a bunch of
> > stuff in TIPC that I guess falls into the category of "seemed like a
> > good idea at the time", but is now just inactive or at best unstable
> > prototype code for things like slave nodes and routing features and
> > mulitcluster support.  My favourite is this one:
> > 
> >  ----------
> > config TIPC_CLUSTERS
> >        int "Maximum number of clusters in a zone"
> >        depends on TIPC_ADVANCED
> >        range 1 1
> >        default "1"
> >        help
> >          Specifies how many clusters can be supported in a TIPC zone.
> > 
> >          *** Currently TIPC only supports a single cluster per zone. ***
> >  ----------
> > 
> > The remaining commits are just de-uglifying what is left, fixing whitespace
> > crimes and other common errors typically picked up in janitor patches.
> 
> All applied, thanks Paul.
> 
> net/tipc/log.h still uses "_TIPC_DBG_H" for it's multiple-include protection
> tests.  Please send me a patch to rename that to _TIPC_LOG_H

Ah crap, I should have spotted that.  Thanks for noticing it.  Patch
follows.

Paul.

----

>From 443eb42b4e3e45b54698ee787ce7e5fb16acb57d Mon Sep 17 00:00:00 2001
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Sat, 1 Jan 2011 17:32:04 -0500
Subject: [PATCH] tipc: update log.h re-include protection to reflect new name

The tipc/dbg.h file was recently renamed to tipc/log.h,
but the re-include define was not updated accordingly.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/log.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/tipc/log.h b/net/tipc/log.h
index f4343bb..2248d96 100644
--- a/net/tipc/log.h
+++ b/net/tipc/log.h
@@ -34,8 +34,8 @@
  * POSSIBILITY OF SUCH DAMAGE.
  */
 
-#ifndef _TIPC_DBG_H
-#define _TIPC_DBG_H
+#ifndef _TIPC_LOG_H
+#define _TIPC_LOG_H
 
 /**
  * struct print_buf - TIPC print buffer structure
-- 
1.7.3.3

