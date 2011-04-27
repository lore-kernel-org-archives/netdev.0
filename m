From: Lifeng Sun <lifongsun@gmail.com>
Subject: [PATCH] Applying inappropriate ioctl operation on socket should return ENOTTY
Date: Wed, 27 Apr 2011 17:32:30 +0800
Message-ID: <1303896750-7039-1-git-send-email-lifongsun@gmail.com>
References: <1303883910.2699.53.camel@edumazet-laptop>
Cc: davem@davemloft.net, Lifeng Sun <lifongsun@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:51242 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752831Ab1D0Jdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 05:33:51 -0400
Received: by pwi15 with SMTP id 15so558000pwi.19
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2011 02:33:51 -0700 (PDT)
In-Reply-To: <1303883910.2699.53.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ioctl() calls against a socket with an inappropriate ioctl operation
are incorrectly returning EINVAL rather than ENOTTY:

  [ENOTTY]
      Inappropriate I/O control operation.

BugLink: https://bugzilla.kernel.org/show_bug.cgi?id=33992

This bug is not limited to socket, it also occurs in a lot of, maybe
some hundred, other ioctl operations, while in the patch I only fixed
about a dozen of additional ones in pipe, fifo and character device
drivers.

Signed-off-by: Lifeng Sun <lifongsun@gmail.com>
---
 drivers/char/applicom.c          |    2 +-
 drivers/char/dtlk.c              |    2 +-
 drivers/char/generic_nvram.c     |    2 +-
 drivers/char/genrtc.c            |    2 +-
 drivers/char/hpet.c              |    2 +-
 drivers/char/i8k.c               |    2 +-
 drivers/char/ipmi/ipmi_devintf.c |    2 +-
 drivers/char/lp.c                |    2 +-
 drivers/char/nwflash.c           |    2 +-
 drivers/char/ppdev.c             |    2 +-
 drivers/char/random.c            |    2 +-
 drivers/char/raw.c               |    4 ++--
 drivers/char/viotape.c           |    2 +-
 fs/pipe.c                        |    2 +-
 net/core/dev.c                   |    6 +++---
 15 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/char/applicom.c b/drivers/char/applicom.c
index 25373df..50c09e4 100644
--- a/drivers/char/applicom.c
+++ b/drivers/char/applicom.c
@@ -838,6 +838,6 @@ static long ac_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	Dummy = readb(apbs[IndexCard].RamIO + VERS);
 	kfree(adgl);
 	mutex_unlock(&ac_mutex);
-	return 0;
+	return ret;
 }
 
diff --git a/drivers/char/dtlk.c b/drivers/char/dtlk.c
index 85156dd..2d116d5 100644
--- a/drivers/char/dtlk.c
+++ b/drivers/char/dtlk.c
@@ -289,7 +289,7 @@ static long dtlk_ioctl(struct file *file,
 		return put_user(portval, argp);
 
 	default:
-		return -EINVAL;
+		return -ENOTTY;
 	}
 }
 
diff --git a/drivers/char/generic_nvram.c b/drivers/char/generic_nvram.c
index 0e941b5..95278e9 100644
--- a/drivers/char/generic_nvram.c
+++ b/drivers/char/generic_nvram.c
@@ -111,7 +111,7 @@ static int nvram_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		nvram_sync();
 		break;
 	default:
-		return -EINVAL;
+		return -ENOTTY;
 	}
 
 	return 0;
diff --git a/drivers/char/genrtc.c b/drivers/char/genrtc.c
index f773a9d..6f4c3da 100644
--- a/drivers/char/genrtc.c
+++ b/drivers/char/genrtc.c
@@ -330,7 +330,7 @@ static int gen_rtc_ioctl(struct file *file,
 	    }
 	}
 
-	return -EINVAL;
+	return -ENOTTY;
 }
 
 static long gen_rtc_unlocked_ioctl(struct file *file, unsigned int cmd,
diff --git a/drivers/char/hpet.c b/drivers/char/hpet.c
index 7066e80..720de66 100644
--- a/drivers/char/hpet.c
+++ b/drivers/char/hpet.c
@@ -575,7 +575,7 @@ hpet_ioctl_common(struct hpet_dev *devp, int cmd, unsigned long arg,
 	case HPET_IE_ON:
 		return hpet_ioctl_ieon(devp);
 	default:
-		return -EINVAL;
+		return -ENOTTY;
 	}
 
 	err = 0;
diff --git a/drivers/char/i8k.c b/drivers/char/i8k.c
index d72433f..4ba9b9f 100644
--- a/drivers/char/i8k.c
+++ b/drivers/char/i8k.c
@@ -370,7 +370,7 @@ i8k_ioctl_unlocked(struct file *fp, unsigned int cmd, unsigned long arg)
 		break;
 
 	default:
-		return -EINVAL;
+		return -ENOTTY;
 	}
 
 	if (val < 0)
diff --git a/drivers/char/ipmi/ipmi_devintf.c b/drivers/char/ipmi/ipmi_devintf.c
index 2aa3977..bc8af5a 100644
--- a/drivers/char/ipmi/ipmi_devintf.c
+++ b/drivers/char/ipmi/ipmi_devintf.c
@@ -232,7 +232,7 @@ static int ipmi_ioctl(struct file   *file,
 		      unsigned int  cmd,
 		      unsigned long data)
 {
-	int                      rv = -EINVAL;
+	int                      rv = -ENOTTY;
 	struct ipmi_file_private *priv = file->private_data;
 	void __user *arg = (void __user *)data;
 
diff --git a/drivers/char/lp.c b/drivers/char/lp.c
index 97c3edb..2ff32c8 100644
--- a/drivers/char/lp.c
+++ b/drivers/char/lp.c
@@ -650,7 +650,7 @@ static int lp_do_ioctl(unsigned int minor, unsigned int cmd,
 			break;
 
 		default:
-			retval = -EINVAL;
+			retval = -ENOTTY;
 	}
 	return retval;
 }
diff --git a/drivers/char/nwflash.c b/drivers/char/nwflash.c
index a12f524..45b7a7a 100644
--- a/drivers/char/nwflash.c
+++ b/drivers/char/nwflash.c
@@ -115,7 +115,7 @@ static long flash_ioctl(struct file *filep, unsigned int cmd, unsigned long arg)
 		gbWriteBase64Enable = 0;
 		gbWriteEnable = 0;
 		mutex_unlock(&flash_mutex);
-		return -EINVAL;
+		return -ENOTTY;
 	}
 	mutex_unlock(&flash_mutex);
 	return 0;
diff --git a/drivers/char/ppdev.c b/drivers/char/ppdev.c
index f176dba..8dce214 100644
--- a/drivers/char/ppdev.c
+++ b/drivers/char/ppdev.c
@@ -622,7 +622,7 @@ static int pp_do_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 
 	default:
 		pr_debug(CHRDEV "%x: What? (cmd=0x%x)\n", minor, cmd);
-		return -EINVAL;
+		return -ENOTTY;
 	}
 
 	/* Keep the compiler happy */
diff --git a/drivers/char/random.c b/drivers/char/random.c
index d4ddeba..40aad1c 100644
--- a/drivers/char/random.c
+++ b/drivers/char/random.c
@@ -1157,7 +1157,7 @@ static long random_ioctl(struct file *f, unsigned int cmd, unsigned long arg)
 		rand_initialize();
 		return 0;
 	default:
-		return -EINVAL;
+		return -ENOTTY;
 	}
 }
 
diff --git a/drivers/char/raw.c b/drivers/char/raw.c
index b4b9d5a..a992bf1 100644
--- a/drivers/char/raw.c
+++ b/drivers/char/raw.c
@@ -231,7 +231,7 @@ static long raw_ctl_ioctl(struct file *filp, unsigned int command,
 		return 0;
 	}
 
-	return -EINVAL;
+	return -ENOTTY;
 }
 
 #ifdef CONFIG_COMPAT
@@ -273,7 +273,7 @@ static long raw_ctl_compat_ioctl(struct file *file, unsigned int cmd,
 		return 0;
 	}
 
-	return -EINVAL;
+	return -ENOTTY;
 }
 #endif
 
diff --git a/drivers/char/viotape.c b/drivers/char/viotape.c
index ad6e64a..a427d40 100644
--- a/drivers/char/viotape.c
+++ b/drivers/char/viotape.c
@@ -529,7 +529,7 @@ static int viotap_ioctl(struct inode *inode, struct file *file,
 
 	down(&reqSem);
 
-	ret = -EINVAL;
+	ret = -ENOTTY;
 
 	switch (cmd) {
 	case MTIOCTOP:
diff --git a/fs/pipe.c b/fs/pipe.c
index da42f7d..fe7ffe4 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -665,7 +665,7 @@ static long pipe_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
 
 			return put_user(count, (int __user *)arg);
 		default:
-			return -EINVAL;
+			return -ENOTTY;
 	}
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index c2ac599..b93c76d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4773,7 +4773,7 @@ static int dev_ifsioc_locked(struct net *net, struct ifreq *ifr, unsigned int cm
 		 * is never reached
 		 */
 		WARN_ON(1);
-		err = -EINVAL;
+		err = -ENOTTY;
 		break;
 
 	}
@@ -5041,7 +5041,7 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 		/* Set the per device memory buffer space.
 		 * Not applicable in our case */
 	case SIOCSIFLINK:
-		return -EINVAL;
+		return -EOPNOTSUPP;
 
 	/*
 	 *	Unknown or private ioctl.
@@ -5062,7 +5062,7 @@ int dev_ioctl(struct net *net, unsigned int cmd, void __user *arg)
 		/* Take care of Wireless Extensions */
 		if (cmd >= SIOCIWFIRST && cmd <= SIOCIWLAST)
 			return wext_handle_ioctl(net, &ifr, cmd, arg);
-		return -EINVAL;
+		return -ENOTTY;
 	}
 }
 
-- 
1.7.5.rc1

