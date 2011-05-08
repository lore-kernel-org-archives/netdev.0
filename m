From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 030/115] sysctl: sched: add sd_table_template
Date: Mon,  9 May 2011 00:38:42 +0200
Message-ID: <1304894407-32201-31-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is just a cleanup patch, it doesn't change any functionality.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 kernel/sched.c |  144 ++++++++++++++++++++++++++++++++++++++++----------------
 1 files changed, 103 insertions(+), 41 deletions(-)

diff --git a/kernel/sched.c b/kernel/sched.c
index 312f8b9..23a980c 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -6092,6 +6092,95 @@ static void migrate_tasks(unsigned int dead_cpu)
 
 #if defined(CONFIG_SCHED_DEBUG) && defined(CONFIG_SYSCTL)
 
+
+static struct ctl_table sd_table_template[] = {
+	{
+		.procname	= "min_interval",
+		/* .data 	= &sd->min_interval, */
+		.maxlen		= sizeof(long),
+		.mode		= 0644,
+		.proc_handler	= proc_doulongvec_minmax,
+	},
+	{
+		.procname	= "max_interval",
+		/* .data 	= &sd->max_interval, */
+		.maxlen		= sizeof(long),
+		.mode		= 0644,
+		.proc_handler	= proc_doulongvec_minmax,
+	},
+	{
+		.procname	= "busy_idx",
+		/* .data 	= &sd->busy_idx, */
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+	},
+	{
+		.procname	= "idle_idx",
+		/* .data 	= &sd->idle_idx, */
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+	},
+	{
+		.procname	= "newidle_idx",
+		/* .data 	= &sd->newidle_idx, */
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+	},
+	{
+		.procname	= "wake_idx",
+		/* .data 	= &sd->wake_idx, */
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+	},
+	{
+		.procname	= "forkexec_idx",
+		/* .data 	= &sd->forkexec_idx, */
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+	},
+	{
+		.procname	= "busy_factor",
+		/* .data 	= &sd->busy_factor, */
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+	},
+	{
+		.procname	= "imbalance_pct",
+		/* .data 	= &sd->imbalance_pct, */
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+	},
+	{
+		.procname	= "cache_nice_tries",
+		/* .data 	= &sd->cache_nice_tries, */
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+	},
+	{
+		.procname	= "flags",
+		/* .data 	= &sd->flags, */
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+	},
+	{
+		.procname	= "name",
+		/* .data 	= sd->name, */
+		.maxlen		= CORENAME_MAX_SIZE,
+		.mode		= 0444,
+		.proc_handler	= proc_dostring,
+	},
+	{ }
+};
+
 static struct ctl_table sd_ctl_dir[] = {
 	{
 		.procname	= "sched_domain",
@@ -6138,52 +6227,25 @@ static void sd_free_ctl_entry(struct ctl_table **tablep)
 	*tablep = NULL;
 }
 
-static void
-set_table_entry(struct ctl_table *entry,
-		const char *procname, void *data, int maxlen,
-		mode_t mode, proc_handler *proc_handler)
-{
-	entry->procname = procname;
-	entry->data = data;
-	entry->maxlen = maxlen;
-	entry->mode = mode;
-	entry->proc_handler = proc_handler;
-}
-
 static struct ctl_table *
 sd_alloc_ctl_domain_table(struct sched_domain *sd)
 {
-	struct ctl_table *table = sd_alloc_ctl_entry(13);
-
+	struct ctl_table *table = kmemdup(&sd_table_template,
+			  sizeof(sd_table_template), GFP_KERNEL);
 	if (table == NULL)
 		return NULL;
-
-	set_table_entry(&table[0], "min_interval", &sd->min_interval,
-		sizeof(long), 0644, proc_doulongvec_minmax);
-	set_table_entry(&table[1], "max_interval", &sd->max_interval,
-		sizeof(long), 0644, proc_doulongvec_minmax);
-	set_table_entry(&table[2], "busy_idx", &sd->busy_idx,
-		sizeof(int), 0644, proc_dointvec_minmax);
-	set_table_entry(&table[3], "idle_idx", &sd->idle_idx,
-		sizeof(int), 0644, proc_dointvec_minmax);
-	set_table_entry(&table[4], "newidle_idx", &sd->newidle_idx,
-		sizeof(int), 0644, proc_dointvec_minmax);
-	set_table_entry(&table[5], "wake_idx", &sd->wake_idx,
-		sizeof(int), 0644, proc_dointvec_minmax);
-	set_table_entry(&table[6], "forkexec_idx", &sd->forkexec_idx,
-		sizeof(int), 0644, proc_dointvec_minmax);
-	set_table_entry(&table[7], "busy_factor", &sd->busy_factor,
-		sizeof(int), 0644, proc_dointvec_minmax);
-	set_table_entry(&table[8], "imbalance_pct", &sd->imbalance_pct,
-		sizeof(int), 0644, proc_dointvec_minmax);
-	set_table_entry(&table[9], "cache_nice_tries",
-		&sd->cache_nice_tries,
-		sizeof(int), 0644, proc_dointvec_minmax);
-	set_table_entry(&table[10], "flags", &sd->flags,
-		sizeof(int), 0644, proc_dointvec_minmax);
-	set_table_entry(&table[11], "name", sd->name,
-		CORENAME_MAX_SIZE, 0444, proc_dostring);
-	/* &table[12] is terminator */
+	table[ 0].data = &sd->min_interval;
+	table[ 1].data = &sd->max_interval;
+	table[ 2].data = &sd->busy_idx;
+	table[ 3].data = &sd->idle_idx;
+	table[ 4].data = &sd->newidle_idx;
+	table[ 5].data = &sd->wake_idx;
+	table[ 6].data = &sd->forkexec_idx;
+	table[ 7].data = &sd->busy_factor;
+	table[ 8].data = &sd->imbalance_pct;
+	table[ 9].data = &sd->cache_nice_tries;
+	table[10].data = &sd->flags;
+	table[11].data =  sd->name;
 
 	return table;
 }
-- 
1.7.5.134.g1c08b
