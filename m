From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the bluetooth tree
Date: Tue, 22 Sep 2015 11:20:15 +1000
Message-ID: <20150922112015.140547fb@canb.auug.org.au>
References: <20150914101428.13d5ec2d@canb.auug.org.au>
	<20150914102234.38df8b11@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>,
	Joe Perches <joe@perches.com>,
	Andrew Morton <akpm@linux-foundation.org>, marcel@holtmann.org
To: Gustavo Padovan <gustavo@padovan.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20150914102234.38df8b11@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Gustavo,

On Mon, 14 Sep 2015 10:22:34 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
>
> On Mon, 14 Sep 2015 10:14:28 +1000 Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> >
> > I applied the patches that Andrew has had in his post merge series
> > (but I think you were sent a rolled up version):
> 
> Actually it was sent by Alexander to Marcel:
> 
> From: Alexander Aring <alex.aring@gmail.com>
> To: marcel@holtmann.org
> Cc: Andrew Morton <akpm@linux-foundation.org>,
> 	Stephen Rothwell <sfr@canb.auug.org.au>,
> 	Alexander Aring <alex.aring@gmail.com>,
> 	Stefan Schmidt <stefan@osg.samsung.com>
> Subject: [PATCH bluetooth-next] drivers/net/ieee802154/at86rf230.c: seq_printf() now returns NULL
> Date: Fri, 11 Sep 2015 11:23:30 +0200
> Message-Id: <1441963410-24844-1-git-send-email-alex.aring@gmail.com>
> X-Mailer: git-send-email 2.5.1
> 
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> I will shortly be sending
> http://ozlabs.org/~akpm/mmots/broken-out/fs-seq_file-convert-int-seq_vprint-seq_printf-etc-returns-to-void.patch
> to Linus.  This will cause the linux-next version of
> drivers/net/ieee802154/at86rf230.c to break at compilation time.
> 
> Below is the fix.  I suggest you apply this immediately.
> 
> Otherwise I'll try to remember to send this in after Alexander's
> 890acf8330cac is merged.  But there will be a window during which the
> build fails, and we'll get emails...
> 
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Subject: drivers/net/ieee802154/at86rf230.c: seq_printf() now returns NULL

OK, this is now a problem for the net-next tree since the bluetooth
tree was merged there :-(

Can someone please apply this patch?

Hi Dave,

An x64_64 allmodconfig build after merging the next-next tree breaks in
linux-next due to the patch below not being applied to the bluetooth
tree.  I have been applying the equivalent to the bluetooth tree merge
in linux-next for a while now.

[Patch repeated for Dave - this is from and email from Andrew via
Alexander to Marcel which I forwarded to Gustavo]

From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: drivers/net/ieee802154/at86rf230.c: seq_printf() now returns NULL

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Alexander Aring <alex.aring@gmail.com>
Cc: Stefan Schmidt <stefan@osg.samsung.com>
Cc: Marcel Holtmann <marcel@holtmann.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 drivers/net/ieee802154/at86rf230.c | 35 ++++++++++-------------------------
 1 file changed, 10 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index b8b0628..9756e64 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -1645,32 +1645,17 @@ static struct dentry *at86rf230_debugfs_root;
 static int at86rf230_stats_show(struct seq_file *file, void *offset)
 {
 	struct at86rf230_local *lp = file->private;
-	int ret;
-
-	ret = seq_printf(file, "SUCCESS:\t\t%8llu\n", lp->trac.success);
-	if (ret < 0)
-		return ret;
-
-	ret = seq_printf(file, "SUCCESS_DATA_PENDING:\t%8llu\n",
-			 lp->trac.success_data_pending);
-	if (ret < 0)
-		return ret;
-
-	ret = seq_printf(file, "SUCCESS_WAIT_FOR_ACK:\t%8llu\n",
-			 lp->trac.success_wait_for_ack);
-	if (ret < 0)
-		return ret;
-
-	ret = seq_printf(file, "CHANNEL_ACCESS_FAILURE:\t%8llu\n",
-			 lp->trac.channel_access_failure);
-	if (ret < 0)
-		return ret;
 
-	ret = seq_printf(file, "NO_ACK:\t\t\t%8llu\n", lp->trac.no_ack);
-	if (ret < 0)
-		return ret;
-
-	return seq_printf(file, "INVALID:\t\t%8llu\n", lp->trac.invalid);
+	seq_printf(file, "SUCCESS:\t\t%8llu\n", lp->trac.success);
+	seq_printf(file, "SUCCESS_DATA_PENDING:\t%8llu\n",
+		   lp->trac.success_data_pending);
+	seq_printf(file, "SUCCESS_WAIT_FOR_ACK:\t%8llu\n",
+		   lp->trac.success_wait_for_ack);
+	seq_printf(file, "CHANNEL_ACCESS_FAILURE:\t%8llu\n",
+		   lp->trac.channel_access_failure);
+	seq_printf(file, "NO_ACK:\t\t\t%8llu\n", lp->trac.no_ack);
+	seq_printf(file, "INVALID:\t\t%8llu\n", lp->trac.invalid);
+	return 0;
 }
 
 static int at86rf230_stats_open(struct inode *inode, struct file *file)
-- 
2.5.1

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
