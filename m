From: "Dr. David Alan Gilbert" <linux@treblig.org>
Subject: [PATCH] kzalloc with swapped params in l2tp_dfs_seq_open
Date: Sun, 31 Oct 2010 17:26:03 +0000
Message-ID: <20101031172603.GB16459@gallifrey>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jchapman@katalix.com, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
  'sparse' spotted that the parameters to kzalloc in l2tp_dfs_seq_open
were swapped.

Tested on current git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git
at 1792f17b7210280a3d7ff29da9614ba779cfcedb  build, boots and I can see that directory,
but there again I could see /sys/kernel/debug/l2tp with it swapped; I don't have
any l2tp in use.

Signed-off-by: Dr. David Alan Gilbert <linux@treblig.org>
--
diff --git a/net/l2tp/l2tp_debugfs.c b/net/l2tp/l2tp_debugfs.c
index 104ec3b..b8dbae8 100644
--- a/net/l2tp/l2tp_debugfs.c
+++ b/net/l2tp/l2tp_debugfs.c
@@ -249,7 +249,7 @@ static int l2tp_dfs_seq_open(struct inode *inode, struct file *file)
 	struct seq_file *seq;
 	int rc = -ENOMEM;
 
-	pd = kzalloc(GFP_KERNEL, sizeof(*pd));
+	pd = kzalloc(sizeof(*pd), GFP_KERNEL);
 	if (pd == NULL)
 		goto out;
 
-- 
 -----Open up your eyes, open up your mind, open up your code -------   
/ Dr. David Alan Gilbert    |       Running GNU/Linux       | Happy  \ 
\ gro.gilbert @ treblig.org |                               | In Hex /
 \ _________________________|_____ http://www.treblig.org   |_______/
