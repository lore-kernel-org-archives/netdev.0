From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 2/7] sysctl: parport remove binary paths.
Date: Fri, 10 Aug 2007 15:01:39 -0600
Message-ID: <m1lkcjw1cc.fsf_-_@ebiederm.dsl.xmission.com>
References: <20070809224254.11f42716.akpm@linux-foundation.org>
	<46BC8F71.3070006@googlemail.com> <46BC944F.9020801@googlemail.com>
	<m1fy2rxpje.fsf@ebiederm.dsl.xmission.com>
	<20070810124156.2de9710e.akpm@linux-foundation.org>
	<m1ps1vw1ey.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gabriel C <nix.or.die@googlemail.com>,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	coreteam@netfilter.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:52134 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754778AbXHJVB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:01:56 -0400
In-Reply-To: <m1ps1vw1ey.fsf_-_@ebiederm.dsl.xmission.com> (Eric
	W. Biederman's message of "Fri, 10 Aug 2007 15:00:05 -0600")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The sysctl binary paths don't look as if they even code work,
.data is not filled in, and all of the proc_handlers look at
extra1 and there is not strategy routine.

So just kill the binary paths.

In addition this patch removes the setting of extra1
on directories.  It doesn't look like the parport code
ever examines it, and it's bad sysctl form.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/parport/procfs.c |   38 +++++---------------------------------
 1 files changed, 5 insertions(+), 33 deletions(-)

diff --git a/drivers/parport/procfs.c b/drivers/parport/procfs.c
index bdbdab9..ed82e41 100644
--- a/drivers/parport/procfs.c
+++ b/drivers/parport/procfs.c
@@ -237,7 +237,7 @@ static int do_hardware_modes (ctl_table *table, int write,
 #define PARPORT_PARPORT_DIR(CHILD) { .ctl_name = DEV_PARPORT, .procname = "parport", \
                                      .mode = 0555, .child = CHILD }
 #define PARPORT_DEV_DIR(CHILD) { .ctl_name = CTL_DEV, .procname = "dev", .mode = 0555, .child = CHILD }
-#define PARPORT_DEVICES_ROOT_DIR  { .ctl_name = DEV_PARPORT_DEVICES, .procname = "devices", \
+#define PARPORT_DEVICES_ROOT_DIR  {  .procname = "devices", \
                                     .mode = 0555, .child = NULL }
 
 static const unsigned long parport_min_timeslice_value =
@@ -266,7 +266,6 @@ static const struct parport_sysctl_table parport_sysctl_template = {
 	.sysctl_header = NULL,
         {
 		{
-			.ctl_name	= DEV_PARPORT_SPINTIME,
 			.procname	= "spintime",
 			.data		= NULL,
 			.maxlen		= sizeof(int),
@@ -276,7 +275,6 @@ static const struct parport_sysctl_table parport_sysctl_template = {
 			.extra2		= (void*) &parport_max_spintime_value
 		},
 		{
-			.ctl_name	= DEV_PARPORT_BASE_ADDR,
 			.procname	= "base-addr",
 			.data		= NULL,
 			.maxlen		= 0,
@@ -284,7 +282,6 @@ static const struct parport_sysctl_table parport_sysctl_template = {
 			.proc_handler	= &do_hardware_base_addr
 		},
 		{
-			.ctl_name	= DEV_PARPORT_IRQ,
 			.procname	= "irq",
 			.data		= NULL,
 			.maxlen		= 0,
@@ -292,7 +289,6 @@ static const struct parport_sysctl_table parport_sysctl_template = {
 			.proc_handler	= &do_hardware_irq
 		},
 		{
-			.ctl_name	= DEV_PARPORT_DMA,
 			.procname	= "dma",
 			.data		= NULL,
 			.maxlen		= 0,
@@ -300,7 +296,6 @@ static const struct parport_sysctl_table parport_sysctl_template = {
 			.proc_handler	= &do_hardware_dma
 		},
 		{
-			.ctl_name	= DEV_PARPORT_MODES,
 			.procname	= "modes",
 			.data		= NULL,
 			.maxlen		= 0,
@@ -310,7 +305,6 @@ static const struct parport_sysctl_table parport_sysctl_template = {
 		PARPORT_DEVICES_ROOT_DIR,
 #ifdef CONFIG_PARPORT_1284
 		{
-			.ctl_name	= DEV_PARPORT_AUTOPROBE,
 			.procname	= "autoprobe",
 			.data		= NULL,
 			.maxlen		= 0,
@@ -318,7 +312,6 @@ static const struct parport_sysctl_table parport_sysctl_template = {
 			.proc_handler	= &do_autoprobe
 		},
 		{
-			.ctl_name	= DEV_PARPORT_AUTOPROBE + 1,
 			.procname	= "autoprobe0",
 			.data		= NULL,
 			.maxlen		= 0,
@@ -326,7 +319,6 @@ static const struct parport_sysctl_table parport_sysctl_template = {
 			.proc_handler	=  &do_autoprobe
 		},
 		{
-			.ctl_name	= DEV_PARPORT_AUTOPROBE + 2,
 			.procname	= "autoprobe1",
 			.data		= NULL,
 			.maxlen		= 0,
@@ -334,7 +326,6 @@ static const struct parport_sysctl_table parport_sysctl_template = {
 			.proc_handler	= &do_autoprobe
 		},
 		{
-			.ctl_name	= DEV_PARPORT_AUTOPROBE + 3,
 			.procname	= "autoprobe2",
 			.data		= NULL,
 			.maxlen		= 0,
@@ -342,7 +333,6 @@ static const struct parport_sysctl_table parport_sysctl_template = {
 			.proc_handler	= &do_autoprobe
 		},
 		{
-			.ctl_name	= DEV_PARPORT_AUTOPROBE + 4,
 			.procname	= "autoprobe3",
 			.data		= NULL,
 			.maxlen		= 0,
@@ -354,7 +344,6 @@ static const struct parport_sysctl_table parport_sysctl_template = {
 	},
 	{
 		{
-			.ctl_name	= DEV_PARPORT_DEVICES_ACTIVE,
 			.procname	= "active",
 			.data		= NULL,
 			.maxlen		= 0,
@@ -393,7 +382,6 @@ parport_device_sysctl_template = {
 	.sysctl_header = NULL,
 	{
 		{
-			.ctl_name 	= DEV_PARPORT_DEVICE_TIMESLICE,
 			.procname 	= "timeslice",
 			.data		= NULL,
 			.maxlen		= sizeof(int),
@@ -449,7 +437,6 @@ parport_default_sysctl_table = {
 	.sysctl_header	= NULL,
 	{
 		{
-			.ctl_name	= DEV_PARPORT_DEFAULT_TIMESLICE,
 			.procname	= "timeslice",
 			.data		= &parport_default_timeslice,
 			.maxlen		= sizeof(parport_default_timeslice),
@@ -459,7 +446,6 @@ parport_default_sysctl_table = {
 			.extra2		= (void*) &parport_max_timeslice_value
 		},
 		{
-			.ctl_name	= DEV_PARPORT_DEFAULT_SPINTIME,
 			.procname	= "spintime",
 			.data		= &parport_default_spintime,
 			.maxlen		= sizeof(parport_default_spintime),
@@ -502,7 +488,7 @@ int parport_proc_register(struct parport *port)
 
 	t->device_dir[0].extra1 = port;
 
-	for (i = 0; i < 8; i++)
+	for (i = 0; i < 5; i++)
 		t->vars[i].extra1 = port;
 
 	t->vars[0].data = &port->spintime;
@@ -512,7 +498,7 @@ int parport_proc_register(struct parport *port)
 		t->vars[6 + i].extra2 = &port->probe_info[i];
 
 	t->port_dir[0].procname = port->name;
-	t->port_dir[0].ctl_name = port->number + 1; /* nb 0 isn't legal here */
+	t->port_dir[0].ctl_name = 0;
 
 	t->port_dir[0].child = t->vars;
 	t->parport_dir[0].child = t->port_dir;
@@ -551,26 +537,12 @@ int parport_device_proc_register(struct pardevice *device)
 	t->dev_dir[0].child = t->parport_dir;
 	t->parport_dir[0].child = t->port_dir;
 	t->port_dir[0].procname = port->name;
-	t->port_dir[0].ctl_name = port->number + 1; /* nb 0 isn't legal here */
+	t->port_dir[0].ctl_name = 0;
 	t->port_dir[0].child = t->devices_root_dir;
 	t->devices_root_dir[0].child = t->device_dir;
 
-#ifdef CONFIG_PARPORT_1284
-
-	t->device_dir[0].ctl_name =
-		parport_device_num(port->number, port->muxport,
-				   device->daisy)
-		+ 1;  /* nb 0 isn't legal here */ 
-
-#else /* No IEEE 1284 support */
-
-	/* parport_device_num isn't available. */
-	t->device_dir[0].ctl_name = 1;
-	
-#endif /* IEEE 1284 support or not */
-
+	t->device_dir[0].ctl_name = 0;
 	t->device_dir[0].procname = device->name;
-	t->device_dir[0].extra1 = device;
 	t->device_dir[0].child = t->vars;
 	t->vars[0].data = &device->timeslice;
 
-- 
1.5.1.1.181.g2de0

