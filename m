From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 1/6] isdn/divert: fix readability damage
Date: Mon, 21 Jan 2013 22:57:20 +0100 (CET)
Message-ID: <20130121-patch-isdn-01.tilman@imap.cc>
References: <20130121-patch-isdn-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:45315 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756654Ab3AUW0r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2013 17:26:47 -0500
In-Reply-To: <20130121-patch-isdn-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix up some of the readibility deterioration caused by last year's
ISDN whitespace coding style cleanup.
Note that the checkpatch complaints all apply to the state of the
source before this patch as well, and in many cases even more so.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/divert/divert_init.c |   33 ++--
 drivers/isdn/divert/isdn_divert.c |  423 ++++++++++++++++++-------------------
 drivers/isdn/divert/isdn_divert.h |   28 ++--
 3 files changed, 237 insertions(+), 247 deletions(-)

diff --git a/drivers/isdn/divert/divert_init.c b/drivers/isdn/divert/divert_init.c
index 5374c25..267dede 100644
--- a/drivers/isdn/divert/divert_init.c
+++ b/drivers/isdn/divert/divert_init.c
@@ -22,13 +22,13 @@ MODULE_LICENSE("GPL");
 /****************************************/
 /* structure containing interface to hl */
 /****************************************/
-isdn_divert_if divert_if =
-{ DIVERT_IF_MAGIC,  /* magic value */
-  DIVERT_CMD_REG,   /* register cmd */
-  ll_callback,      /* callback routine from ll */
-  NULL,             /* command still not specified */
-  NULL,             /* drv_to_name */
-  NULL,             /* name_to_drv */
+isdn_divert_if divert_if = {
+	DIVERT_IF_MAGIC,	/* magic value */
+	DIVERT_CMD_REG,		/* register cmd */
+	ll_callback,		/* callback routine from ll */
+	NULL,			/* command still not specified */
+	NULL,			/* drv_to_name */
+	NULL,			/* name_to_drv */
 };
 
 /*************************/
@@ -36,14 +36,15 @@ isdn_divert_if divert_if =
 /* no cmd line parms     */
 /*************************/
 static int __init divert_init(void)
-{ int i;
+{
+	int i;
 
-	if (divert_dev_init())
-	{ printk(KERN_WARNING "dss1_divert: cannot install device, not loaded\n");
+	if (divert_dev_init()) {
+		printk(KERN_WARNING "dss1_divert: cannot install device, not loaded\n");
 		return (-EIO);
 	}
-	if ((i = DIVERT_REG_NAME(&divert_if)) != DIVERT_NO_ERR)
-	{ divert_dev_deinit();
+	if ((i = DIVERT_REG_NAME(&divert_if)) != DIVERT_NO_ERR) {
+		divert_dev_deinit();
 		printk(KERN_WARNING "dss1_divert: error %d registering module, not loaded\n", i);
 		return (-EIO);
 	}
@@ -61,13 +62,13 @@ static void __exit divert_exit(void)
 
 	spin_lock_irqsave(&divert_lock, flags);
 	divert_if.cmd = DIVERT_CMD_REL; /* release */
-	if ((i = DIVERT_REG_NAME(&divert_if)) != DIVERT_NO_ERR)
-	{ printk(KERN_WARNING "dss1_divert: error %d releasing module\n", i);
+	if ((i = DIVERT_REG_NAME(&divert_if)) != DIVERT_NO_ERR) {
+		printk(KERN_WARNING "dss1_divert: error %d releasing module\n", i);
 		spin_unlock_irqrestore(&divert_lock, flags);
 		return;
 	}
-	if (divert_dev_deinit())
-	{ printk(KERN_WARNING "dss1_divert: device busy, remove cancelled\n");
+	if (divert_dev_deinit()) {
+		printk(KERN_WARNING "dss1_divert: device busy, remove cancelled\n");
 		spin_unlock_irqrestore(&divert_lock, flags);
 		return;
 	}
diff --git a/drivers/isdn/divert/isdn_divert.c b/drivers/isdn/divert/isdn_divert.c
index e61e55f..db432e6 100644
--- a/drivers/isdn/divert/isdn_divert.c
+++ b/drivers/isdn/divert/isdn_divert.c
@@ -19,8 +19,8 @@
 /**********************************/
 /* structure keeping calling info */
 /**********************************/
-struct call_struc
-{ isdn_ctrl ics; /* delivered setup + driver parameters */
+struct call_struc {
+	isdn_ctrl ics; /* delivered setup + driver parameters */
 	ulong divert_id; /* Id delivered to user */
 	unsigned char akt_state; /* actual state */
 	char deflect_dest[35]; /* deflection destination */
@@ -34,8 +34,8 @@ struct call_struc
 /********************************************/
 /* structure keeping deflection table entry */
 /********************************************/
-struct deflect_struc
-{ struct deflect_struc *next, *prev;
+struct deflect_struc {
+	struct deflect_struc *next, *prev;
 	divert_rule rule; /* used rule */
 };
 
@@ -64,16 +64,16 @@ static void deflect_timer_expire(ulong arg)
 	del_timer(&cs->timer); /* delete active timer */
 	spin_unlock_irqrestore(&divert_lock, flags);
 
-	switch (cs->akt_state)
-	{ case DEFLECT_PROCEED:
-			cs->ics.command = ISDN_CMD_HANGUP; /* cancel action */
-			divert_if.ll_cmd(&cs->ics);
-			spin_lock_irqsave(&divert_lock, flags);
-			cs->akt_state = DEFLECT_AUTODEL; /* delete after timeout */
-			cs->timer.expires = jiffies + (HZ * AUTODEL_TIME);
-			add_timer(&cs->timer);
-			spin_unlock_irqrestore(&divert_lock, flags);
-			break;
+	switch (cs->akt_state) {
+	case DEFLECT_PROCEED:
+		cs->ics.command = ISDN_CMD_HANGUP; /* cancel action */
+		divert_if.ll_cmd(&cs->ics);
+		spin_lock_irqsave(&divert_lock, flags);
+		cs->akt_state = DEFLECT_AUTODEL; /* delete after timeout */
+		cs->timer.expires = jiffies + (HZ * AUTODEL_TIME);
+		add_timer(&cs->timer);
+		spin_unlock_irqrestore(&divert_lock, flags);
+		break;
 
 	case DEFLECT_ALERT:
 		cs->ics.command = ISDN_CMD_REDIR; /* protocol */
@@ -111,7 +111,8 @@ static void deflect_timer_expire(ulong arg)
 int cf_command(int drvid, int mode,
 	       u_char proc, char *msn,
 	       u_char service, char *fwd_nr, ulong *procid)
-{ unsigned long flags;
+{
+	unsigned long flags;
 	int retval, msnlen;
 	int fwd_len;
 	char *p, *ielenp, tmp[60];
@@ -130,8 +131,8 @@ int cf_command(int drvid, int mode,
 	*p++ = 1;   /* length */
 	*p++ = service; /* service to handle */
 
-	if (mode == 1)
-	{ if (!*fwd_nr) return (-EINVAL); /* destination missing */
+	if (mode == 1) {
+		if (!*fwd_nr) return (-EINVAL); /* destination missing */
 		if (strchr(fwd_nr, '.')) return (-EINVAL); /* subaddress not allowed */
 		fwd_len = strlen(fwd_nr);
 		*p++ = 0x30; /* number enumeration */
@@ -144,12 +145,12 @@ int cf_command(int drvid, int mode,
 
 	msnlen = strlen(msn);
 	*p++ = 0x80; /* msn number */
-	if (msnlen > 1)
-	{ *p++ = msnlen; /* length */
+	if (msnlen > 1) {
+		*p++ = msnlen; /* length */
 		strcpy(p, msn);
 		p += msnlen;
-	}
-	else *p++ = 0;
+	} else
+		*p++ = 0;
 
 	*ielenp = p - ielenp - 1; /* set total IE length */
 
@@ -186,14 +187,13 @@ int cf_command(int drvid, int mode,
 
 	retval = divert_if.ll_cmd(&cs->ics); /* execute command */
 
-	if (!retval)
-	{ cs->prev = NULL;
+	if (!retval) {
+		cs->prev = NULL;
 		spin_lock_irqsave(&divert_lock, flags);
 		cs->next = divert_head;
 		divert_head = cs;
 		spin_unlock_irqrestore(&divert_lock, flags);
-	}
-	else
+	} else
 		kfree(cs);
 	return (retval);
 } /* cf_command */
@@ -203,15 +203,16 @@ int cf_command(int drvid, int mode,
 /* handle a external deflection command */
 /****************************************/
 int deflect_extern_action(u_char cmd, ulong callid, char *to_nr)
-{ struct call_struc *cs;
+{
+	struct call_struc *cs;
 	isdn_ctrl ic;
 	unsigned long flags;
 	int i;
 
 	if ((cmd & 0x7F) > 2) return (-EINVAL); /* invalid command */
 	cs = divert_head; /* start of parameter list */
-	while (cs)
-	{ if (cs->divert_id == callid) break; /* found */
+	while (cs) {
+		if (cs->divert_id == callid) break; /* found */
 		cs = cs->next;
 	} /* search entry */
 	if (!cs) return (-EINVAL); /* invalid callid */
@@ -220,32 +221,30 @@ int deflect_extern_action(u_char cmd, ulong callid, char *to_nr)
 	ic.arg = cs->ics.arg;
 	i = -EINVAL;
 	if (cs->akt_state == DEFLECT_AUTODEL) return (i); /* no valid call */
-	switch (cmd & 0x7F)
-	{ case 0: /* hangup */
-			del_timer(&cs->timer);
-			ic.command = ISDN_CMD_HANGUP;
-			i = divert_if.ll_cmd(&ic);
-			spin_lock_irqsave(&divert_lock, flags);
-			cs->akt_state = DEFLECT_AUTODEL; /* delete after timeout */
-			cs->timer.expires = jiffies + (HZ * AUTODEL_TIME);
-			add_timer(&cs->timer);
-			spin_unlock_irqrestore(&divert_lock, flags);
-			break;
+	switch (cmd & 0x7F) {
+	case 0: /* hangup */
+		del_timer(&cs->timer);
+		ic.command = ISDN_CMD_HANGUP;
+		i = divert_if.ll_cmd(&ic);
+		spin_lock_irqsave(&divert_lock, flags);
+		cs->akt_state = DEFLECT_AUTODEL; /* delete after timeout */
+		cs->timer.expires = jiffies + (HZ * AUTODEL_TIME);
+		add_timer(&cs->timer);
+		spin_unlock_irqrestore(&divert_lock, flags);
+		break;
 
 	case 1: /* alert */
 		if (cs->akt_state == DEFLECT_ALERT) return (0);
 		cmd &= 0x7F; /* never wait */
 		del_timer(&cs->timer);
 		ic.command = ISDN_CMD_ALERT;
-		if ((i = divert_if.ll_cmd(&ic)))
-		{
+		if ((i = divert_if.ll_cmd(&ic))) {
 			spin_lock_irqsave(&divert_lock, flags);
 			cs->akt_state = DEFLECT_AUTODEL; /* delete after timeout */
 			cs->timer.expires = jiffies + (HZ * AUTODEL_TIME);
 			add_timer(&cs->timer);
 			spin_unlock_irqrestore(&divert_lock, flags);
-		}
-		else
+		} else
 			cs->akt_state = DEFLECT_ALERT;
 		break;
 
@@ -254,15 +253,13 @@ int deflect_extern_action(u_char cmd, ulong callid, char *to_nr)
 		strlcpy(cs->ics.parm.setup.phone, to_nr, sizeof(cs->ics.parm.setup.phone));
 		strcpy(cs->ics.parm.setup.eazmsn, "Testtext manual");
 		ic.command = ISDN_CMD_REDIR;
-		if ((i = divert_if.ll_cmd(&ic)))
-		{
+		if ((i = divert_if.ll_cmd(&ic))) {
 			spin_lock_irqsave(&divert_lock, flags);
 			cs->akt_state = DEFLECT_AUTODEL; /* delete after timeout */
 			cs->timer.expires = jiffies + (HZ * AUTODEL_TIME);
 			add_timer(&cs->timer);
 			spin_unlock_irqrestore(&divert_lock, flags);
-		}
-		else
+		} else
 			cs->akt_state = DEFLECT_ALERT;
 		break;
 
@@ -274,19 +271,19 @@ int deflect_extern_action(u_char cmd, ulong callid, char *to_nr)
 /* insert a new rule before idx */
 /********************************/
 int insertrule(int idx, divert_rule *newrule)
-{ struct deflect_struc *ds, *ds1 = NULL;
+{
+	struct deflect_struc *ds, *ds1 = NULL;
 	unsigned long flags;
 
-	if (!(ds = kmalloc(sizeof(struct deflect_struc),
-			   GFP_KERNEL)))
+	if (!(ds = kmalloc(sizeof(struct deflect_struc), GFP_KERNEL)))
 		return (-ENOMEM); /* no memory */
 
 	ds->rule = *newrule; /* set rule */
 
 	spin_lock_irqsave(&divert_lock, flags);
 
-	if (idx >= 0)
-	{ ds1 = table_head;
+	if (idx >= 0) {
+		ds1 = table_head;
 		while ((ds1) && (idx > 0))
 		{ idx--;
 			ds1 = ds1->next;
@@ -294,17 +291,16 @@ int insertrule(int idx, divert_rule *newrule)
 		if (!ds1) idx = -1;
 	}
 
-	if (idx < 0)
-	{ ds->prev = table_tail; /* previous entry */
+	if (idx < 0) {
+		ds->prev = table_tail; /* previous entry */
 		ds->next = NULL; /* end of chain */
 		if (ds->prev)
 			ds->prev->next = ds; /* last forward */
 		else
 			table_head = ds; /* is first entry */
 		table_tail = ds; /* end of queue */
-	}
-	else
-	{ ds->next = ds1; /* next entry */
+	} else {
+		ds->next = ds1; /* next entry */
 		ds->prev = ds1->prev; /* prev entry */
 		ds1->prev = ds; /* backward chain old element */
 		if (!ds->prev)
@@ -319,17 +315,18 @@ int insertrule(int idx, divert_rule *newrule)
 /* delete the rule at position idx */
 /***********************************/
 int deleterule(int idx)
-{ struct deflect_struc *ds, *ds1;
+{
+	struct deflect_struc *ds, *ds1;
 	unsigned long flags;
 
-	if (idx < 0)
-	{ spin_lock_irqsave(&divert_lock, flags);
+	if (idx < 0) {
+		spin_lock_irqsave(&divert_lock, flags);
 		ds = table_head;
 		table_head = NULL;
 		table_tail = NULL;
 		spin_unlock_irqrestore(&divert_lock, flags);
-		while (ds)
-		{ ds1 = ds;
+		while (ds) {
+			ds1 = ds;
 			ds = ds->next;
 			kfree(ds1);
 		}
@@ -339,13 +336,12 @@ int deleterule(int idx)
 	spin_lock_irqsave(&divert_lock, flags);
 	ds = table_head;
 
-	while ((ds) && (idx > 0))
-	{ idx--;
+	while ((ds) && (idx > 0)) {
+		idx--;
 		ds = ds->next;
 	}
 
-	if (!ds)
-	{
+	if (!ds) {
 		spin_unlock_irqrestore(&divert_lock, flags);
 		return (-EINVAL);
 	}
@@ -369,12 +365,13 @@ int deleterule(int idx)
 /* get a pointer to a specific rule number */
 /*******************************************/
 divert_rule *getruleptr(int idx)
-{ struct deflect_struc *ds = table_head;
+{
+	struct deflect_struc *ds = table_head;
 
 	if (idx < 0) return (NULL);
-	while ((ds) && (idx >= 0))
-	{ if (!(idx--))
-		{ return (&ds->rule);
+	while ((ds) && (idx >= 0)) {
+		if (!(idx--)) {
+			return (&ds->rule);
 			break;
 		}
 		ds = ds->next;
@@ -386,7 +383,8 @@ divert_rule *getruleptr(int idx)
 /* called from common module on an incoming call */
 /*************************************************/
 static int isdn_divert_icall(isdn_ctrl *ic)
-{ int retval = 0;
+{
+	int retval = 0;
 	unsigned long flags;
 	struct call_struc *cs = NULL;
 	struct deflect_struc *dv;
@@ -394,8 +392,8 @@ static int isdn_divert_icall(isdn_ctrl *ic)
 	u_char accept;
 
 	/* first check the internal deflection table */
-	for (dv = table_head; dv; dv = dv->next)
-	{ /* scan table */
+	for (dv = table_head; dv; dv = dv->next) {
+		/* scan table */
 		if (((dv->rule.callopt == 1) && (ic->command == ISDN_STAT_ICALLW)) ||
 		    ((dv->rule.callopt == 2) && (ic->command == ISDN_STAT_ICALL)))
 			continue; /* call option check */
@@ -409,10 +407,10 @@ static int isdn_divert_icall(isdn_ctrl *ic)
 		p = dv->rule.my_msn;
 		p1 = ic->parm.setup.eazmsn;
 		accept = 0;
-		while (*p)
-		{ /* complete compare */
-			if (*p == '-')
-			{ accept = 1; /* call accepted */
+		while (*p) {
+			/* complete compare */
+			if (*p == '-') {
+				accept = 1; /* call accepted */
 				break;
 			}
 			if (*p++ != *p1++)
@@ -422,14 +420,15 @@ static int isdn_divert_icall(isdn_ctrl *ic)
 		} /* complete compare */
 		if (!accept) continue; /* not accepted */
 
-		if ((strcmp(dv->rule.caller, "0")) || (ic->parm.setup.phone[0]))
-		{ p = dv->rule.caller;
+		if ((strcmp(dv->rule.caller, "0")) ||
+		    (ic->parm.setup.phone[0])) {
+			p = dv->rule.caller;
 			p1 = ic->parm.setup.phone;
 			accept = 0;
-			while (*p)
-			{ /* complete compare */
-				if (*p == '-')
-				{ accept = 1; /* call accepted */
+			while (*p) {
+				/* complete compare */
+				if (*p == '-') {
+					accept = 1; /* call accepted */
 					break;
 				}
 				if (*p++ != *p1++)
@@ -440,10 +439,10 @@ static int isdn_divert_icall(isdn_ctrl *ic)
 			if (!accept) continue; /* not accepted */
 		}
 
-		switch (dv->rule.action)
-		{ case DEFLECT_IGNORE:
-				return (0);
-				break;
+		switch (dv->rule.action) {
+		case DEFLECT_IGNORE:
+			return (0);
+			break;
 
 		case DEFLECT_ALERT:
 		case DEFLECT_PROCEED:
@@ -465,31 +464,29 @@ static int isdn_divert_icall(isdn_ctrl *ic)
 			cs->ics.parm.setup.screen = dv->rule.screen;
 			if (dv->rule.waittime)
 				cs->timer.expires = jiffies + (HZ * dv->rule.waittime);
+			else if (dv->rule.action == DEFLECT_PROCEED)
+				cs->timer.expires = jiffies + (HZ * extern_wait_max);
 			else
-				if (dv->rule.action == DEFLECT_PROCEED)
-					cs->timer.expires = jiffies + (HZ * extern_wait_max);
-				else
-					cs->timer.expires = 0;
+				cs->timer.expires = 0;
 			cs->akt_state = dv->rule.action;
 			spin_lock_irqsave(&divert_lock, flags);
 			cs->divert_id = next_id++; /* new sequence number */
 			spin_unlock_irqrestore(&divert_lock, flags);
 			cs->prev = NULL;
-			if (cs->akt_state == DEFLECT_ALERT)
-			{ strcpy(cs->deflect_dest, dv->rule.to_nr);
-				if (!cs->timer.expires)
-				{ strcpy(ic->parm.setup.eazmsn, "Testtext direct");
+			if (cs->akt_state == DEFLECT_ALERT) {
+				strcpy(cs->deflect_dest, dv->rule.to_nr);
+				if (!cs->timer.expires) {
+					strcpy(ic->parm.setup.eazmsn,
+					       "Testtext direct");
 					ic->parm.setup.screen = dv->rule.screen;
 					strlcpy(ic->parm.setup.phone, dv->rule.to_nr, sizeof(ic->parm.setup.phone));
 					cs->akt_state = DEFLECT_AUTODEL; /* delete after timeout */
 					cs->timer.expires = jiffies + (HZ * AUTODEL_TIME);
 					retval = 5;
-				}
-				else
+				} else
 					retval = 1; /* alerting */
-			}
-			else
-			{ cs->deflect_dest[0] = '\0';
+			} else {
+				cs->deflect_dest[0] = '\0';
 				retval = 4; /* only proceed */
 			}
 			sprintf(cs->info, "%d 0x%lx %s %s %s %s 0x%x 0x%x %d %d %s\n",
@@ -505,8 +502,8 @@ static int isdn_divert_icall(isdn_ctrl *ic)
 				dv->rule.waittime,
 				cs->deflect_dest);
 			if ((dv->rule.action == DEFLECT_REPORT) ||
-			    (dv->rule.action == DEFLECT_REJECT))
-			{ put_info_buffer(cs->info);
+			    (dv->rule.action == DEFLECT_REJECT)) {
+				put_info_buffer(cs->info);
 				kfree(cs); /* remove */
 				return ((dv->rule.action == DEFLECT_REPORT) ? 0 : 2); /* nothing to do */
 			}
@@ -519,8 +516,8 @@ static int isdn_divert_icall(isdn_ctrl *ic)
 		break;
 	} /* scan_table */
 
-	if (cs)
-	{ cs->prev = NULL;
+	if (cs) {
+		cs->prev = NULL;
 		spin_lock_irqsave(&divert_lock, flags);
 		cs->next = divert_head;
 		divert_head = cs;
@@ -529,21 +526,21 @@ static int isdn_divert_icall(isdn_ctrl *ic)
 
 		put_info_buffer(cs->info);
 		return (retval);
-	}
-	else
+	} else
 		return (0);
 } /* isdn_divert_icall */
 
 
 void deleteprocs(void)
-{ struct call_struc *cs, *cs1;
+{
+	struct call_struc *cs, *cs1;
 	unsigned long flags;
 
 	spin_lock_irqsave(&divert_lock, flags);
 	cs = divert_head;
 	divert_head = NULL;
-	while (cs)
-	{ del_timer(&cs->timer);
+	while (cs) {
+		del_timer(&cs->timer);
 		cs1 = cs;
 		cs = cs->next;
 		kfree(cs1);
@@ -555,12 +552,13 @@ void deleteprocs(void)
 /* put a address including address type into buffer */
 /****************************************************/
 static int put_address(char *st, u_char *p, int len)
-{ u_char retval = 0;
+{
+	u_char retval = 0;
 	u_char adr_typ = 0; /* network standard */
 
 	if (len < 2) return (retval);
-	if (*p == 0xA1)
-	{ retval = *(++p) + 2; /* total length */
+	if (*p == 0xA1) {
+		retval = *(++p) + 2; /* total length */
 		if (retval > len) return (0); /* too short */
 		len = retval - 2; /* remaining length */
 		if (len < 3) return (0);
@@ -572,16 +570,13 @@ static int put_address(char *st, u_char *p, int len)
 		if (*p++ != 0x12) return (0);
 		if (*p > len) return (0); /* check number length */
 		len = *p++;
-	}
-	else
-		if (*p == 0x80)
-		{ retval = *(++p) + 2; /* total length */
-			if (retval > len) return (0);
-			len = retval - 2;
-			p++;
-		}
-		else
-			return (0); /* invalid address information */
+	} else if (*p == 0x80) {
+		retval = *(++p) + 2; /* total length */
+		if (retval > len) return (0);
+		len = retval - 2;
+		p++;
+	} else
+		return (0); /* invalid address information */
 
 	sprintf(st, "%d ", adr_typ);
 	st += strlen(st);
@@ -598,7 +593,8 @@ static int put_address(char *st, u_char *p, int len)
 /* report a successful interrogation */
 /*************************************/
 static int interrogate_success(isdn_ctrl *ic, struct call_struc *cs)
-{ char *src = ic->parm.dss1_io.data;
+{
+	char *src = ic->parm.dss1_io.data;
 	int restlen = ic->parm.dss1_io.datalen;
 	int cnt = 1;
 	u_char n, n1;
@@ -608,50 +604,44 @@ static int interrogate_success(isdn_ctrl *ic, struct call_struc *cs)
 	if (*src++ != 0x30) return (-101);
 	if ((n = *src++) > 0x81) return (-102); /* invalid length field */
 	restlen -= 2; /* remaining bytes */
-	if (n == 0x80)
-	{ if (restlen < 2) return (-103);
+	if (n == 0x80) {
+		if (restlen < 2) return (-103);
 		if ((*(src + restlen - 1)) || (*(src + restlen - 2))) return (-104);
 		restlen -= 2;
-	}
+	} else if (n == 0x81) {
+		n = *src++;
+		restlen--;
+		if (n > restlen) return (-105);
+		restlen = n;
+	} else if (n > restlen)
+		return (-106);
 	else
-		if (n == 0x81)
-		{ n = *src++;
-			restlen--;
-			if (n > restlen) return (-105);
-			restlen = n;
-		}
-		else
-			if (n > restlen) return (-106);
-			else
-				restlen = n; /* standard format */
+		restlen = n; /* standard format */
 	if (restlen < 3) return (-107); /* no procedure */
 	if ((*src++ != 2) || (*src++ != 1) || (*src++ != 0x0B)) return (-108);
 	restlen -= 3;
 	if (restlen < 2) return (-109); /* list missing */
-	if (*src == 0x31)
-	{ src++;
+	if (*src == 0x31) {
+		src++;
 		if ((n = *src++) > 0x81) return (-110); /* invalid length field */
 		restlen -= 2; /* remaining bytes */
-		if (n == 0x80)
-		{ if (restlen < 2) return (-111);
+		if (n == 0x80) {
+			if (restlen < 2) return (-111);
 			if ((*(src + restlen - 1)) || (*(src + restlen - 2))) return (-112);
 			restlen -= 2;
-		}
+		} else if (n == 0x81) {
+			n = *src++;
+			restlen--;
+			if (n > restlen) return (-113);
+			restlen = n;
+		} else if (n > restlen)
+			return (-114);
 		else
-			if (n == 0x81)
-			{ n = *src++;
-				restlen--;
-				if (n > restlen) return (-113);
-				restlen = n;
-			}
-			else
-				if (n > restlen) return (-114);
-				else
-					restlen = n; /* standard format */
+			restlen = n; /* standard format */
 	} /* result list header */
 
-	while (restlen >= 2)
-	{ stp = st;
+	while (restlen >= 2) {
+		stp = st;
 		sprintf(stp, "%d 0x%lx %d %s ", DIVERT_REPORT, ic->parm.dss1_io.ll_id,
 			cnt++, divert_if.drv_to_name(ic->driver));
 		stp += strlen(stp);
@@ -674,8 +664,8 @@ static int interrogate_success(isdn_ctrl *ic, struct call_struc *cs)
 		sprintf(stp, "%d ", (*p++) & 0xFF);
 		stp += strlen(stp);
 		n -= 6;
-		if (n > 2)
-		{ if (*p++ != 0x30) continue;
+		if (n > 2) {
+			if (*p++ != 0x30) continue;
 			if (*p > (n - 2)) continue;
 			n = *p++;
 			if (!(n1 = put_address(stp, p, n & 0xFF))) continue;
@@ -692,58 +682,58 @@ static int interrogate_success(isdn_ctrl *ic, struct call_struc *cs)
 /* callback for protocol specific extensions */
 /*********************************************/
 static int prot_stat_callback(isdn_ctrl *ic)
-{ struct call_struc *cs, *cs1;
+{
+	struct call_struc *cs, *cs1;
 	int i;
 	unsigned long flags;
 
 	cs = divert_head; /* start of list */
 	cs1 = NULL;
-	while (cs)
-	{ if (ic->driver == cs->ics.driver)
-		{ switch (cs->ics.arg)
-			{ case DSS1_CMD_INVOKE:
-					if ((cs->ics.parm.dss1_io.ll_id == ic->parm.dss1_io.ll_id) &&
-					    (cs->ics.parm.dss1_io.hl_id == ic->parm.dss1_io.hl_id))
-					{ switch (ic->arg)
-						{  case DSS1_STAT_INVOKE_ERR:
-								sprintf(cs->info, "128 0x%lx 0x%x\n",
-									ic->parm.dss1_io.ll_id,
-									ic->parm.dss1_io.timeout);
-								put_info_buffer(cs->info);
-								break;
-
-						case DSS1_STAT_INVOKE_RES:
-							switch (cs->ics.parm.dss1_io.proc)
-							{  case  7:
-							case  8:
-								put_info_buffer(cs->info);
-								break;
-
-							case  11:
-								i = interrogate_success(ic, cs);
-								if (i)
-									sprintf(cs->info, "%d 0x%lx %d\n", DIVERT_REPORT,
-										ic->parm.dss1_io.ll_id, i);
-								put_info_buffer(cs->info);
-								break;
-
-							default:
-								printk(KERN_WARNING "dss1_divert: unknown proc %d\n", cs->ics.parm.dss1_io.proc);
-								break;
-							}
-
+	while (cs) {
+		if (ic->driver == cs->ics.driver) {
+			switch (cs->ics.arg) {
+			case DSS1_CMD_INVOKE:
+				if ((cs->ics.parm.dss1_io.ll_id == ic->parm.dss1_io.ll_id) &&
+				    (cs->ics.parm.dss1_io.hl_id == ic->parm.dss1_io.hl_id)) {
+					switch (ic->arg) {
+					case DSS1_STAT_INVOKE_ERR:
+						sprintf(cs->info, "128 0x%lx 0x%x\n",
+							ic->parm.dss1_io.ll_id,
+							ic->parm.dss1_io.timeout);
+						put_info_buffer(cs->info);
+						break;
+
+					case DSS1_STAT_INVOKE_RES:
+						switch (cs->ics.parm.dss1_io.proc) {
+						case  7:
+						case  8:
+							put_info_buffer(cs->info);
+							break;
 
+						case  11:
+							i = interrogate_success(ic, cs);
+							if (i)
+								sprintf(cs->info, "%d 0x%lx %d\n", DIVERT_REPORT,
+									ic->parm.dss1_io.ll_id, i);
+							put_info_buffer(cs->info);
 							break;
 
 						default:
-							printk(KERN_WARNING "dss1_divert unknown invoke answer %lx\n", ic->arg);
+							printk(KERN_WARNING "dss1_divert: unknown proc %d\n", cs->ics.parm.dss1_io.proc);
 							break;
 						}
-						cs1 = cs; /* remember structure */
-						cs = NULL;
-						continue; /* abort search */
-					} /* id found */
-					break;
+
+						break;
+
+					default:
+						printk(KERN_WARNING "dss1_divert unknown invoke answer %lx\n", ic->arg);
+						break;
+					}
+					cs1 = cs; /* remember structure */
+					cs = NULL;
+					continue; /* abort search */
+				} /* id found */
+				break;
 
 			case DSS1_CMD_INVOKE_ABORT:
 				printk(KERN_WARNING "dss1_divert unhandled invoke abort\n");
@@ -757,13 +747,12 @@ static int prot_stat_callback(isdn_ctrl *ic)
 		} /* driver ok */
 	}
 
-	if (!cs1)
-	{ printk(KERN_WARNING "dss1_divert unhandled process\n");
+	if (!cs1) {
+		printk(KERN_WARNING "dss1_divert unhandled process\n");
 		return (0);
 	}
 
-	if (cs1->ics.driver == -1)
-	{
+	if (cs1->ics.driver == -1) {
 		spin_lock_irqsave(&divert_lock, flags);
 		del_timer(&cs1->timer);
 		if (cs1->prev)
@@ -784,20 +773,22 @@ static int prot_stat_callback(isdn_ctrl *ic)
 /* status callback from HL */
 /***************************/
 static int isdn_divert_stat_callback(isdn_ctrl *ic)
-{ struct call_struc *cs, *cs1;
+{
+	struct call_struc *cs, *cs1;
 	unsigned long flags;
 	int retval;
 
 	retval = -1;
 	cs = divert_head; /* start of list */
-	while (cs)
-	{ if ((ic->driver == cs->ics.driver) && (ic->arg == cs->ics.arg))
-		{ switch (ic->command)
-			{ case ISDN_STAT_DHUP:
-					sprintf(cs->info, "129 0x%lx\n", cs->divert_id);
-					del_timer(&cs->timer);
-					cs->ics.driver = -1;
-					break;
+	while (cs) {
+		if ((ic->driver == cs->ics.driver) &&
+		    (ic->arg == cs->ics.arg)) {
+			switch (ic->command) {
+			case ISDN_STAT_DHUP:
+				sprintf(cs->info, "129 0x%lx\n", cs->divert_id);
+				del_timer(&cs->timer);
+				cs->ics.driver = -1;
+				break;
 
 			case ISDN_STAT_CAUSE:
 				sprintf(cs->info, "130 0x%lx %s\n", cs->divert_id, ic->parm.num);
@@ -818,8 +809,7 @@ static int isdn_divert_stat_callback(isdn_ctrl *ic)
 		}
 		cs1 = cs;
 		cs = cs->next;
-		if (cs1->ics.driver == -1)
-		{
+		if (cs1->ics.driver == -1) {
 			spin_lock_irqsave(&divert_lock, flags);
 			if (cs1->prev)
 				cs1->prev->next = cs1->next; /* forward link */
@@ -840,20 +830,19 @@ static int isdn_divert_stat_callback(isdn_ctrl *ic)
 /********************/
 int ll_callback(isdn_ctrl *ic)
 {
-	switch (ic->command)
-	{ case ISDN_STAT_ICALL:
+	switch (ic->command) {
+	case ISDN_STAT_ICALL:
 	case ISDN_STAT_ICALLW:
 		return (isdn_divert_icall(ic));
 		break;
 
 	case ISDN_STAT_PROT:
-		if ((ic->arg & 0xFF) == ISDN_PTYPE_EURO)
-		{ if (ic->arg != DSS1_STAT_INVOKE_BRD)
+		if ((ic->arg & 0xFF) == ISDN_PTYPE_EURO) {
+			if (ic->arg != DSS1_STAT_INVOKE_BRD)
 				return (prot_stat_callback(ic));
 			else
 				return (0); /* DSS1 invoke broadcast */
-		}
-		else
+		} else
 			return (-1); /* protocol not euro */
 
 	default:
diff --git a/drivers/isdn/divert/isdn_divert.h b/drivers/isdn/divert/isdn_divert.h
index 42f2893..55033dd 100644
--- a/drivers/isdn/divert/isdn_divert.h
+++ b/drivers/isdn/divert/isdn_divert.h
@@ -43,8 +43,8 @@
 
 #define DEFLECT_ALL_IDS   0xFFFFFFFF /* all drivers selected */
 
-typedef struct
-{ ulong drvid;     /* driver ids, bit mapped */
+typedef struct {
+	ulong drvid;     /* driver ids, bit mapped */
 	char my_msn[35]; /* desired msn, subaddr allowed */
 	char caller[35]; /* caller id, partial string with * + subaddr allowed */
 	char to_nr[35];  /* deflected to number incl. subaddress */
@@ -65,18 +65,18 @@ typedef struct
 	u_char waittime; /* maximum wait time for proceeding */
 } divert_rule;
 
-typedef union
-{ int drv_version; /* return of driver version */
-	struct
-	{ int drvid;		/* id of driver */
+typedef union {
+	int drv_version; /* return of driver version */
+	struct {
+		int drvid;		/* id of driver */
 		char drvnam[30];	/* name of driver */
 	} getid;
-	struct
-	{ int ruleidx;	/* index of rule */
+	struct {
+		int ruleidx;	/* index of rule */
 		divert_rule rule;	/* rule parms */
 	} getsetrule;
-	struct
-	{ u_char subcmd;  /* 0 = hangup/reject,
+	struct {
+		u_char subcmd;  /* 0 = hangup/reject,
 			     1 = alert,
 			     2 = deflect */
 		ulong callid;   /* id of call delivered by ascii output */
@@ -84,8 +84,8 @@ typedef union
 				   else uus1 string (maxlen 31),
 				   data from rule used if empty */
 	} fwd_ctrl;
-	struct
-	{ int drvid;      /* id of driver */
+	struct {
+		int drvid;      /* id of driver */
 		u_char cfproc;  /* cfu = 0, cfb = 1, cfnr = 2 */
 		ulong procid;   /* process id returned when no error */
 		u_char service; /* basically coded service, 0 = all */
@@ -104,8 +104,8 @@ typedef union
 /**************************************************/
 /* structure keeping ascii info for device output */
 /**************************************************/
-struct divert_info
-{ struct divert_info *next;
+struct divert_info {
+	struct divert_info *next;
 	ulong usage_cnt; /* number of files still to work */
 	char info_start[2]; /* info string start */
 };
-- 
1.7.3.4
