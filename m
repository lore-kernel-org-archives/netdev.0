From: Emese Revfy <re.emese@gmail.com>
Subject: Re: [PATCH 11/31] Constify struct file_operations for 2.6.32 v1
Date: Mon, 07 Dec 2009 01:45:02 +0100
Message-ID: <4B1C500E.5040406@gmail.com>
References: <4B198670.2000406@gmail.com> <4B198C43.50205@gmail.com> <4B19A333.5080103@gmail.com> <20091205000942.GA8224@suse.de> <4B19CA6F.4090700@gmail.com> <20091205041507.GA24885@suse.de> <4B1B0D40.3040209@gmail.com> <20091206172526.GA17480@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lenb@kernel.org, astarikovskiy@suse.de, mchehab@infradead.org,
	linville@tuxdriver.com, miklos@szeredi.hu, davem@davemloft.net,
	rostedt@goodmis.org, fweisbec@gmail.com, mingo@redhat.com,
	avi@redhat.com, mtosatti@redhat.com, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:37075 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754960AbZLGAnx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Dec 2009 19:43:53 -0500
In-Reply-To: <20091206172526.GA17480@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH wrote:
> On Sun, Dec 06, 2009 at 02:47:44AM +0100, Emese Revfy wrote:
>> Greg KH wrote:
>>> On Sat, Dec 05, 2009 at 03:50:23AM +0100, Emese Revfy wrote:
>>>> Greg KH wrote:
>>>>> On Sat, Dec 05, 2009 at 01:02:59AM +0100, Emese Revfy wrote:
>>>>>> -static struct file_operations ptmx_fops;
>>>>>> +static const struct file_operations ptmx_fops = {
>>>>>> +	.llseek		= no_llseek,
>>>>>> +	.read		= tty_read,
>>>>>> +	.write		= tty_write,
>>>>>> +	.poll		= tty_poll,
>>>>>> +	.unlocked_ioctl	= tty_ioctl,
>>>>>> +	.compat_ioctl	= tty_compat_ioctl,
>>>>>> +	.open		= ptmx_open,
>>>>>> +	.release	= tty_release,
>>>>>> +	.fasync		= tty_fasync,
>>>>>> +};
>>>>> You just made these functions all global, for no real good reason.  Why
>>>>> did you do this?
>>>> I think this is the only way to make ptmx_fops const, provided we want to. 
>>> Why do we want to?
>> Because I saw that checkpatch.pl itself tries to ensure the same I went
>> through the whole tree looking for non-const file_operations structures
>> and tried to make them const as best as I could. If you think making
>> ptmx_fops const is not worth the effort I will remove it from the patch.
> 
> Based on the patch, I would think it is not worth it.
> 
> thanks,
> 
> greg k-h
> 
Ok, I removed the affected hunks.

From: Emese Revfy <re.emese@gmail.com>

Constify struct file_operations with some exceptions.

Signed-off-by: Emese Revfy <re.emese@gmail.com>
---
 drivers/acpi/battery.c                           |    2 +-
 drivers/char/pty.c                               |    1 +
 drivers/char/tty_io.c                            |    1 +
 drivers/media/dvb/dvb-core/dvbdev.c              |    1 +
 drivers/net/wireless/b43/debugfs.c               |    2 +-
 drivers/net/wireless/b43legacy/debugfs.c         |    2 +-
 drivers/net/wireless/libertas/debugfs.c          |    2 +-
 drivers/staging/b3dfg/b3dfg.c                    |    2 +-
 drivers/staging/dream/qdsp5/adsp_driver.c        |    2 +-
 drivers/staging/dream/qdsp5/audio_aac.c          |    2 +-
 drivers/staging/dream/qdsp5/audio_amrnb.c        |    2 +-
 drivers/staging/dream/qdsp5/audio_evrc.c         |    2 +-
 drivers/staging/dream/qdsp5/audio_in.c           |    4 ++--
 drivers/staging/dream/qdsp5/audio_mp3.c          |    2 +-
 drivers/staging/dream/qdsp5/audio_out.c          |    4 ++--
 drivers/staging/dream/qdsp5/audio_qcelp.c        |    2 +-
 drivers/staging/dream/qdsp5/snd.c                |    2 +-
 drivers/staging/dream/smd/smd_qmi.c              |    2 +-
 drivers/staging/dream/smd/smd_rpcrouter_device.c |    4 ++--
 drivers/staging/panel/panel.c                    |    4 ++--
 drivers/staging/poch/poch.c                      |    2 +-
 drivers/staging/sep/sep_driver.c                 |    2 +-
 drivers/staging/vme/devices/vme_user.c           |    2 +-
 fs/char_dev.c                                    |    1 +
 fs/fuse/cuse.c                                   |   19 ++++++++++++-------
 fs/fuse/dev.c                                    |    8 ++++----
 fs/fuse/fuse_i.h                                 |   10 ++++++++++
 virt/kvm/kvm_main.c                              |    3 +++
 28 files changed, 57 insertions(+), 35 deletions(-)

diff --git a/drivers/acpi/battery.c b/drivers/acpi/battery.c
index 3f4602b..2e41d36 100644
--- a/drivers/acpi/battery.c
+++ b/drivers/acpi/battery.c
@@ -763,7 +763,7 @@ DECLARE_FILE_FUNCTIONS(alarm);
 	}
 
 static struct battery_file {
-	struct file_operations ops;
+	const struct file_operations ops;
 	mode_t mode;
 	const char *name;
 } acpi_battery_file[] = {
diff --git a/drivers/char/pty.c b/drivers/char/pty.c
index 62f282e..96e29e5 100644
--- a/drivers/char/pty.c
+++ b/drivers/char/pty.c
@@ -682,6 +682,7 @@ static int ptmx_open(struct inode *inode, struct file *filp)
 	return ret;
 }
 
+/* cannot be const, see unix98_pty_init */
 static struct file_operations ptmx_fops;
 
 static void __init unix98_pty_init(void)
diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
index 59499ee..97616a9 100644
--- a/drivers/char/tty_io.c
+++ b/drivers/char/tty_io.c
@@ -3046,6 +3046,7 @@ struct tty_struct *get_current_tty(void)
 }
 EXPORT_SYMBOL_GPL(get_current_tty);
 
+/* cannot be const, see this function */
 void tty_default_fops(struct file_operations *fops)
 {
 	*fops = tty_fops;
diff --git a/drivers/media/dvb/dvb-core/dvbdev.c b/drivers/media/dvb/dvb-core/dvbdev.c
index 94159b9..9684961 100644
--- a/drivers/media/dvb/dvb-core/dvbdev.c
+++ b/drivers/media/dvb/dvb-core/dvbdev.c
@@ -191,6 +191,7 @@ int dvb_register_device(struct dvb_adapter *adap, struct dvb_device **pdvbdev,
 			const struct dvb_device *template, void *priv, int type)
 {
 	struct dvb_device *dvbdev;
+	/* cannot be const, see this function */
 	struct file_operations *dvbdevfops;
 	struct device *clsdev;
 	int minor;
diff --git a/drivers/net/wireless/b43/debugfs.c b/drivers/net/wireless/b43/debugfs.c
index 80b19a4..dab3a45 100644
--- a/drivers/net/wireless/b43/debugfs.c
+++ b/drivers/net/wireless/b43/debugfs.c
@@ -43,7 +43,7 @@ static struct dentry *rootdir;
 struct b43_debugfs_fops {
 	ssize_t (*read)(struct b43_wldev *dev, char *buf, size_t bufsize);
 	int (*write)(struct b43_wldev *dev, const char *buf, size_t count);
-	struct file_operations fops;
+	const struct file_operations fops;
 	/* Offset of struct b43_dfs_file in struct b43_dfsentry */
 	size_t file_struct_offset;
 };
diff --git a/drivers/net/wireless/b43legacy/debugfs.c b/drivers/net/wireless/b43legacy/debugfs.c
index 1f85ac5..c99b4b4 100644
--- a/drivers/net/wireless/b43legacy/debugfs.c
+++ b/drivers/net/wireless/b43legacy/debugfs.c
@@ -44,7 +44,7 @@ static struct dentry *rootdir;
 struct b43legacy_debugfs_fops {
 	ssize_t (*read)(struct b43legacy_wldev *dev, char *buf, size_t bufsize);
 	int (*write)(struct b43legacy_wldev *dev, const char *buf, size_t count);
-	struct file_operations fops;
+	const struct file_operations fops;
 	/* Offset of struct b43legacy_dfs_file in struct b43legacy_dfsentry */
 	size_t file_struct_offset;
 	/* Take wl->irq_lock before calling read/write? */
diff --git a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless/libertas/debugfs.c
index 893a55c..7f66a50 100644
--- a/drivers/net/wireless/libertas/debugfs.c
+++ b/drivers/net/wireless/libertas/debugfs.c
@@ -708,7 +708,7 @@ out_unlock:
 struct lbs_debugfs_files {
 	const char *name;
 	int perm;
-	struct file_operations fops;
+	const struct file_operations fops;
 };
 
 static const struct lbs_debugfs_files debugfs_files[] = {
diff --git a/drivers/staging/b3dfg/b3dfg.c b/drivers/staging/b3dfg/b3dfg.c
index cda26bb..25f3ec6 100644
--- a/drivers/staging/b3dfg/b3dfg.c
+++ b/drivers/staging/b3dfg/b3dfg.c
@@ -848,7 +848,7 @@ static int b3dfg_mmap(struct file *filp, struct vm_area_struct *vma)
 	return r;
 }
 
-static struct file_operations b3dfg_fops = {
+static const struct file_operations b3dfg_fops = {
 	.owner = THIS_MODULE,
 	.open = b3dfg_open,
 	.release = b3dfg_release,
diff --git a/drivers/staging/dream/qdsp5/adsp_driver.c b/drivers/staging/dream/qdsp5/adsp_driver.c
index e55a0db..577b776 100644
--- a/drivers/staging/dream/qdsp5/adsp_driver.c
+++ b/drivers/staging/dream/qdsp5/adsp_driver.c
@@ -576,7 +576,7 @@ static struct adsp_device *inode_to_device(struct inode *inode)
 static dev_t adsp_devno;
 static struct class *adsp_class;
 
-static struct file_operations adsp_fops = {
+static const struct file_operations adsp_fops = {
 	.owner = THIS_MODULE,
 	.open = adsp_open,
 	.unlocked_ioctl = adsp_ioctl,
diff --git a/drivers/staging/dream/qdsp5/audio_aac.c b/drivers/staging/dream/qdsp5/audio_aac.c
index ad2390f..4116ee8 100644
--- a/drivers/staging/dream/qdsp5/audio_aac.c
+++ b/drivers/staging/dream/qdsp5/audio_aac.c
@@ -1022,7 +1022,7 @@ done:
 	return rc;
 }
 
-static struct file_operations audio_aac_fops = {
+static const struct file_operations audio_aac_fops = {
 	.owner = THIS_MODULE,
 	.open = audio_open,
 	.release = audio_release,
diff --git a/drivers/staging/dream/qdsp5/audio_amrnb.c b/drivers/staging/dream/qdsp5/audio_amrnb.c
index cd818a5..870b37b 100644
--- a/drivers/staging/dream/qdsp5/audio_amrnb.c
+++ b/drivers/staging/dream/qdsp5/audio_amrnb.c
@@ -833,7 +833,7 @@ done:
 	return rc;
 }
 
-static struct file_operations audio_amrnb_fops = {
+static const struct file_operations audio_amrnb_fops = {
 	.owner = THIS_MODULE,
 	.open = audamrnb_open,
 	.release = audamrnb_release,
diff --git a/drivers/staging/dream/qdsp5/audio_evrc.c b/drivers/staging/dream/qdsp5/audio_evrc.c
index 4b43e18..cedafda 100644
--- a/drivers/staging/dream/qdsp5/audio_evrc.c
+++ b/drivers/staging/dream/qdsp5/audio_evrc.c
@@ -805,7 +805,7 @@ dma_fail:
 	return rc;
 }
 
-static struct file_operations audio_evrc_fops = {
+static const struct file_operations audio_evrc_fops = {
 	.owner = THIS_MODULE,
 	.open = audevrc_open,
 	.release = audevrc_release,
diff --git a/drivers/staging/dream/qdsp5/audio_in.c b/drivers/staging/dream/qdsp5/audio_in.c
index 3d950a2..9431118 100644
--- a/drivers/staging/dream/qdsp5/audio_in.c
+++ b/drivers/staging/dream/qdsp5/audio_in.c
@@ -913,7 +913,7 @@ static int audpre_open(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static struct file_operations audio_fops = {
+static const struct file_operations audio_fops = {
 	.owner		= THIS_MODULE,
 	.open		= audio_in_open,
 	.release	= audio_in_release,
@@ -922,7 +922,7 @@ static struct file_operations audio_fops = {
 	.unlocked_ioctl	= audio_in_ioctl,
 };
 
-static struct file_operations audpre_fops = {
+static const struct file_operations audpre_fops = {
 	.owner          = THIS_MODULE,
 	.open           = audpre_open,
 	.unlocked_ioctl = audpre_ioctl,
diff --git a/drivers/staging/dream/qdsp5/audio_mp3.c b/drivers/staging/dream/qdsp5/audio_mp3.c
index b95574f..286c2f4 100644
--- a/drivers/staging/dream/qdsp5/audio_mp3.c
+++ b/drivers/staging/dream/qdsp5/audio_mp3.c
@@ -941,7 +941,7 @@ done:
 	return rc;
 }
 
-static struct file_operations audio_mp3_fops = {
+static const struct file_operations audio_mp3_fops = {
 	.owner		= THIS_MODULE,
 	.open		= audio_open,
 	.release	= audio_release,
diff --git a/drivers/staging/dream/qdsp5/audio_out.c b/drivers/staging/dream/qdsp5/audio_out.c
index d1adcf6..f8f9833 100644
--- a/drivers/staging/dream/qdsp5/audio_out.c
+++ b/drivers/staging/dream/qdsp5/audio_out.c
@@ -810,7 +810,7 @@ static int audpp_open(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static struct file_operations audio_fops = {
+static const struct file_operations audio_fops = {
 	.owner		= THIS_MODULE,
 	.open		= audio_open,
 	.release	= audio_release,
@@ -819,7 +819,7 @@ static struct file_operations audio_fops = {
 	.unlocked_ioctl	= audio_ioctl,
 };
 
-static struct file_operations audpp_fops = {
+static const struct file_operations audpp_fops = {
 	.owner		= THIS_MODULE,
 	.open		= audpp_open,
 	.unlocked_ioctl	= audpp_ioctl,
diff --git a/drivers/staging/dream/qdsp5/audio_qcelp.c b/drivers/staging/dream/qdsp5/audio_qcelp.c
index f0f50e3..f6b9dbc 100644
--- a/drivers/staging/dream/qdsp5/audio_qcelp.c
+++ b/drivers/staging/dream/qdsp5/audio_qcelp.c
@@ -816,7 +816,7 @@ err:
 	return rc;
 }
 
-static struct file_operations audio_qcelp_fops = {
+static const struct file_operations audio_qcelp_fops = {
 	.owner = THIS_MODULE,
 	.open = audqcelp_open,
 	.release = audqcelp_release,
diff --git a/drivers/staging/dream/qdsp5/snd.c b/drivers/staging/dream/qdsp5/snd.c
index 037d7ff..5469ec3 100644
--- a/drivers/staging/dream/qdsp5/snd.c
+++ b/drivers/staging/dream/qdsp5/snd.c
@@ -242,7 +242,7 @@ err:
 	return rc;
 }
 
-static struct file_operations snd_fops = {
+static const struct file_operations snd_fops = {
 	.owner		= THIS_MODULE,
 	.open		= snd_open,
 	.release	= snd_release,
diff --git a/drivers/staging/dream/smd/smd_qmi.c b/drivers/staging/dream/smd/smd_qmi.c
index d4e7d88..0ea632a 100644
--- a/drivers/staging/dream/smd/smd_qmi.c
+++ b/drivers/staging/dream/smd/smd_qmi.c
@@ -793,7 +793,7 @@ static int qmi_release(struct inode *ip, struct file *fp)
 	return 0;
 }
 
-static struct file_operations qmi_fops = {
+static const struct file_operations qmi_fops = {
 	.owner = THIS_MODULE,
 	.read = qmi_read,
 	.write = qmi_write,
diff --git a/drivers/staging/dream/smd/smd_rpcrouter_device.c b/drivers/staging/dream/smd/smd_rpcrouter_device.c
index cd3910b..ff053d3 100644
--- a/drivers/staging/dream/smd/smd_rpcrouter_device.c
+++ b/drivers/staging/dream/smd/smd_rpcrouter_device.c
@@ -214,7 +214,7 @@ static long rpcrouter_ioctl(struct file *filp, unsigned int cmd,
 	return rc;
 }
 
-static struct file_operations rpcrouter_server_fops = {
+static const struct file_operations rpcrouter_server_fops = {
 	.owner	 = THIS_MODULE,
 	.open	 = rpcrouter_open,
 	.release = rpcrouter_release,
@@ -224,7 +224,7 @@ static struct file_operations rpcrouter_server_fops = {
 	.unlocked_ioctl	 = rpcrouter_ioctl,
 };
 
-static struct file_operations rpcrouter_router_fops = {
+static const struct file_operations rpcrouter_router_fops = {
 	.owner	 = THIS_MODULE,
 	.open	 = rpcrouter_open,
 	.release = rpcrouter_release,
diff --git a/drivers/staging/panel/panel.c b/drivers/staging/panel/panel.c
index 4ce399b..225f9bc 100644
--- a/drivers/staging/panel/panel.c
+++ b/drivers/staging/panel/panel.c
@@ -1305,7 +1305,7 @@ static int lcd_release(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static struct file_operations lcd_fops = {
+static const struct file_operations lcd_fops = {
 	.write   = lcd_write,
 	.open    = lcd_open,
 	.release = lcd_release,
@@ -1565,7 +1565,7 @@ static int keypad_release(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static struct file_operations keypad_fops = {
+static const struct file_operations keypad_fops = {
 	.read    = keypad_read,		/* read */
 	.open    = keypad_open,		/* open */
 	.release = keypad_release,	/* close */
diff --git a/drivers/staging/poch/poch.c b/drivers/staging/poch/poch.c
index 2eb8e3d..57616a7 100644
--- a/drivers/staging/poch/poch.c
+++ b/drivers/staging/poch/poch.c
@@ -1057,7 +1057,7 @@ static int poch_ioctl(struct inode *inode, struct file *filp,
 	return 0;
 }
 
-static struct file_operations poch_fops = {
+static const struct file_operations poch_fops = {
 	.owner = THIS_MODULE,
 	.open = poch_open,
 	.release = poch_release,
diff --git a/drivers/staging/sep/sep_driver.c b/drivers/staging/sep/sep_driver.c
index f890a16..509ece8 100644
--- a/drivers/staging/sep/sep_driver.c
+++ b/drivers/staging/sep/sep_driver.c
@@ -2603,7 +2603,7 @@ static struct pci_driver sep_pci_driver = {
 static dev_t sep_devno;
 
 /* the files operations structure of the driver */
-static struct file_operations sep_file_operations = {
+static const struct file_operations sep_file_operations = {
 	.owner = THIS_MODULE,
 	.ioctl = sep_ioctl,
 	.poll = sep_poll,
diff --git a/drivers/staging/vme/devices/vme_user.c b/drivers/staging/vme/devices/vme_user.c
index 7891288..8e31300 100644
--- a/drivers/staging/vme/devices/vme_user.c
+++ b/drivers/staging/vme/devices/vme_user.c
@@ -136,7 +136,7 @@ static int vme_user_ioctl(struct inode *, struct file *, unsigned int,
 static int __init vme_user_probe(struct device *, int, int);
 static int __exit vme_user_remove(struct device *, int, int);
 
-static struct file_operations vme_user_fops = {
+static const struct file_operations vme_user_fops = {
         .open = vme_user_open,
         .release = vme_user_release,
         .read = vme_user_read,
diff --git a/fs/char_dev.c b/fs/char_dev.c
index d6db933..7b47e79 100644
--- a/fs/char_dev.c
+++ b/fs/char_dev.c
@@ -547,6 +547,7 @@ struct cdev *cdev_alloc(void)
  * Initializes @cdev, remembering @fops, making it ready to add to the
  * system with cdev_add().
  */
+
 void cdev_init(struct cdev *cdev, const struct file_operations *fops)
 {
 	memset(cdev, 0, sizeof *cdev);
diff --git a/fs/fuse/cuse.c b/fs/fuse/cuse.c
index de792dc..2115e7f 100644
--- a/fs/fuse/cuse.c
+++ b/fs/fuse/cuse.c
@@ -528,7 +528,18 @@ static int cuse_channel_release(struct inode *inode, struct file *file)
 	return rc;
 }
 
-static struct file_operations cuse_channel_fops; /* initialized during init */
+static const struct file_operations cuse_channel_fops = { /* initialized during init */
+	.owner		= THIS_MODULE,
+	.llseek		= no_llseek,
+	.read		= do_sync_read,
+	.aio_read	= fuse_dev_read,
+	.write		= do_sync_write,
+	.aio_write	= fuse_dev_write,
+	.poll		= fuse_dev_poll,
+	.open		= cuse_channel_open,
+	.release	= cuse_channel_release,
+	.fasync		= fuse_dev_fasync,
+};
 
 
 /**************************************************************************
@@ -575,12 +586,6 @@ static int __init cuse_init(void)
 	for (i = 0; i < CUSE_CONNTBL_LEN; i++)
 		INIT_LIST_HEAD(&cuse_conntbl[i]);
 
-	/* inherit and extend fuse_dev_operations */
-	cuse_channel_fops		= fuse_dev_operations;
-	cuse_channel_fops.owner		= THIS_MODULE;
-	cuse_channel_fops.open		= cuse_channel_open;
-	cuse_channel_fops.release	= cuse_channel_release;
-
 	cuse_class = class_create(THIS_MODULE, "cuse");
 	if (IS_ERR(cuse_class))
 		return PTR_ERR(cuse_class);
diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
index 51d9e33..03c8f95 100644
--- a/fs/fuse/dev.c
+++ b/fs/fuse/dev.c
@@ -745,7 +745,7 @@ __releases(&fc->lock)
  * request_end().  Otherwise add it to the processing list, and set
  * the 'sent' flag.
  */
-static ssize_t fuse_dev_read(struct kiocb *iocb, const struct iovec *iov,
+ssize_t fuse_dev_read(struct kiocb *iocb, const struct iovec *iov,
 			      unsigned long nr_segs, loff_t pos)
 {
 	int err;
@@ -987,7 +987,7 @@ static int copy_out_args(struct fuse_copy_state *cs, struct fuse_out *out,
  * it from the list and copy the rest of the buffer to the request.
  * The request is finished by calling request_end()
  */
-static ssize_t fuse_dev_write(struct kiocb *iocb, const struct iovec *iov,
+ssize_t fuse_dev_write(struct kiocb *iocb, const struct iovec *iov,
 			       unsigned long nr_segs, loff_t pos)
 {
 	int err;
@@ -1084,7 +1084,7 @@ static ssize_t fuse_dev_write(struct kiocb *iocb, const struct iovec *iov,
 	return err;
 }
 
-static unsigned fuse_dev_poll(struct file *file, poll_table *wait)
+unsigned fuse_dev_poll(struct file *file, poll_table *wait)
 {
 	unsigned mask = POLLOUT | POLLWRNORM;
 	struct fuse_conn *fc = fuse_get_conn(file);
@@ -1210,7 +1210,7 @@ int fuse_dev_release(struct inode *inode, struct file *file)
 }
 EXPORT_SYMBOL_GPL(fuse_dev_release);
 
-static int fuse_dev_fasync(int fd, struct file *file, int on)
+int fuse_dev_fasync(int fd, struct file *file, int on)
 {
 	struct fuse_conn *fc = fuse_get_conn(file);
 	if (!fc)
diff --git a/fs/fuse/fuse_i.h b/fs/fuse/fuse_i.h
index 01cc462..b11fe78 100644
--- a/fs/fuse/fuse_i.h
+++ b/fs/fuse/fuse_i.h
@@ -521,6 +521,16 @@ extern const struct file_operations fuse_dev_operations;
 
 extern const struct dentry_operations fuse_dentry_operations;
 
+extern ssize_t fuse_dev_read(struct kiocb *iocb, const struct iovec *iov,
+			      unsigned long nr_segs, loff_t pos);
+
+extern ssize_t fuse_dev_write(struct kiocb *iocb, const struct iovec *iov,
+			       unsigned long nr_segs, loff_t pos);
+
+extern unsigned fuse_dev_poll(struct file *file, poll_table *wait);
+
+extern int fuse_dev_fasync(int fd, struct file *file, int on);
+
 /**
  * Inode to nodeid comparison.
  */
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 7495ce3..3ddb0c8 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1745,6 +1745,7 @@ static int kvm_vcpu_release(struct inode *inode, struct file *filp)
 	return 0;
 }
 
+/* cannot be const, see kvm_init */
 static struct file_operations kvm_vcpu_fops = {
 	.release        = kvm_vcpu_release,
 	.unlocked_ioctl = kvm_vcpu_ioctl,
@@ -2341,6 +2342,7 @@ static int kvm_vm_mmap(struct file *file, struct vm_area_struct *vma)
 	return 0;
 }
 
+/* cannot be const, see kvm_init */
 static struct file_operations kvm_vm_fops = {
 	.release        = kvm_vm_release,
 	.unlocked_ioctl = kvm_vm_ioctl,
@@ -2428,6 +2430,7 @@ out:
 	return r;
 }
 
+/* cannot be const, see kvm_init */
 static struct file_operations kvm_chardev_ops = {
 	.unlocked_ioctl = kvm_dev_ioctl,
 	.compat_ioctl   = kvm_dev_ioctl,
