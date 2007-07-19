From: "rae l" <crquan@gmail.com>
Subject: Re: [PATCH 1/2] nbd: use list_for_each_entry_safe to make it more consolidated and readable
Date: Fri, 20 Jul 2007 00:48:29 +0800
Message-ID: <91b13c310707190948j4eee14eauf53dd1c72c7fdb8a@mail.gmail.com>
References: <11848376711601-git-send-email-crquan@gmail.com>
	 <469F7F58.4080709@steeleye.com>
	 <91b13c310707190855h6fee9604pcc86b6712d2c76f8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Pavel Machek" <pavel@ucw.cz>,
	"Steven Whitehouse" <steve@chygwyn.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	debra <chdebra@gmail.com>
To: "Paul Clements" <paul.clements@steeleye.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:5517 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933360AbXGSQsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 12:48:31 -0400
Received: by ug-out-1314.google.com with SMTP id j3so447458ugf
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2007 09:48:29 -0700 (PDT)
In-Reply-To: <91b13c310707190855h6fee9604pcc86b6712d2c76f8@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/19/07, rae l <crquan@gmail.com> wrote:
> On 7/19/07, Paul Clements <paul.clements@steeleye.com> wrote:
> > Could you name "n" as "tmp" (as in the previous code) so that it's clear
> > that's only a temporary variable. Other than that, this looks good.
> Sure. I just use the name "n" as in the declaration of
> list_for_each_entry_safe in the header file <linux/list.h>
> I'll resend it a little later.

Signed-off-by: Denis Cheng <crquan@gmail.com>
---
 drivers/block/nbd.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/block/nbd.c b/drivers/block/nbd.c
index c129510..86639c0 100644
--- a/drivers/block/nbd.c
+++ b/drivers/block/nbd.c
@@ -237,8 +237,7 @@ error_out:

 static struct request *nbd_find_request(struct nbd_device *lo, char *handle)
 {
-	struct request *req;
-	struct list_head *tmp;
+	struct request *req, *tmp;
 	struct request *xreq;
 	int err;

@@ -249,8 +248,7 @@ static struct request *nbd_find_request(struct
nbd_device *lo, char *handle)
 		goto out;

 	spin_lock(&lo->queue_lock);
-	list_for_each(tmp, &lo->queue_head) {
-		req = list_entry(tmp, struct request, queuelist);
+	list_for_each_entry_safe(req, tmp, &lo->queue_head, queuelist) {
 		if (req != xreq)
 			continue;
 		list_del_init(&req->queuelist);

-- 
Denis Cheng
Linux Application Developer

"One of my most productive days was throwing away 1000 lines of code."
 - Ken Thompson.
