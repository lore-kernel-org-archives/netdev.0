From: Roland McGrath <roland@redhat.com>
Subject: Re: [PATCH 1/2] avoid OPEN_MAX in SCM_MAX_FD
Date: Tue, 13 Mar 2007 13:02:56 -0700 (PDT)
Message-ID: <20070313200256.CF7411801C5@magilla.sf.frob.com>
References: <20070313141750.GH6209@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37331 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933104AbXCMUDc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Mar 2007 16:03:32 -0400
In-Reply-To: Benjamin LaHaise's message of  Tuesday, 13 March 2007 10:17:50 -0400 <20070313141750.GH6209@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > -#define SCM_MAX_FD	(OPEN_MAX-1)
> > +#define SCM_MAX_FD	(NR_OPEN-1)
> 
> This is a bad idea.  [...]

Ok.  My only agenda is to get rid of OPEN_MAX.
I then propose the following instead.


Thanks,
Roland

---
[PATCH] avoid OPEN_MAX in SCM_MAX_FD

The OPEN_MAX constant is an arbitrary number with no useful relation to
anything.  Nothing should be using it.  SCM_MAX_FD is just an arbitrary
constant and it should be clear that its value is chosen in net/scm.h
and not actually derived from anything else meaningful in the system.

Signed-off-by: Roland McGrath <roland@redhat.com>
---
 include/net/scm.h |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/include/net/scm.h b/include/net/scm.h
index 5637d5e..2240690 100644  
--- a/include/net/scm.h
+++ b/include/net/scm.h
@@ -8,7 +8,7 @@
 /* Well, we should have at least one descriptor open
  * to accept passed FDs 8)
  */
-#define SCM_MAX_FD	(OPEN_MAX-1)
+#define SCM_MAX_FD	255
 
 struct scm_fp_list
 {
