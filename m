From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 1/2] kernel: Make compat bitmap functions externally visible
Date: Tue, 19 May 2015 12:01:48 -0700
Message-ID: <1432062109-1472984-2-git-send-email-tom@herbertland.com>
References: <1432062109-1472984-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:44663 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751317AbbESTCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 15:02:09 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t4JIvvWH028239
	for <netdev@vger.kernel.org>; Tue, 19 May 2015 12:02:08 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1ug95rgjbw-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 19 May 2015 12:02:08 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 8b0f95aafe5911e48a100002c991e86a-72fd43a0 for <netdev@vger.kernel.org>;	Tue,
 19 May 2015 12:02:06 -0700
In-Reply-To: <1432062109-1472984-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export compat_get_bitmap and compat_put_bitmap. Make
compat_get_user_cpu_mask not static, add prototype in compat.h, and
export it.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/compat.h | 2 ++
 kernel/compat.c        | 7 +++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/compat.h b/include/linux/compat.h
index ab25814..b52bc0c 100644
--- a/include/linux/compat.h
+++ b/include/linux/compat.h
@@ -380,6 +380,8 @@ long compat_get_bitmap(unsigned long *mask, const compat_ulong_t __user *umask,
 		       unsigned long bitmap_size);
 long compat_put_bitmap(compat_ulong_t __user *umask, unsigned long *mask,
 		       unsigned long bitmap_size);
+int compat_get_user_cpu_mask(compat_ulong_t __user *user_mask_ptr,
+			     unsigned len, struct cpumask *new_mask);
 int copy_siginfo_from_user32(siginfo_t *to, struct compat_siginfo __user *from);
 int copy_siginfo_to_user32(struct compat_siginfo __user *to, const siginfo_t *from);
 int get_compat_sigevent(struct sigevent *event,
diff --git a/kernel/compat.c b/kernel/compat.c
index 24f0061..0b74ad9 100644
--- a/kernel/compat.c
+++ b/kernel/compat.c
@@ -599,8 +599,8 @@ COMPAT_SYSCALL_DEFINE5(waitid,
 	return copy_siginfo_to_user32(uinfo, &info);
 }
 
-static int compat_get_user_cpu_mask(compat_ulong_t __user *user_mask_ptr,
-				    unsigned len, struct cpumask *new_mask)
+int compat_get_user_cpu_mask(compat_ulong_t __user *user_mask_ptr,
+			     unsigned len, struct cpumask *new_mask)
 {
 	unsigned long *k;
 
@@ -612,6 +612,7 @@ static int compat_get_user_cpu_mask(compat_ulong_t __user *user_mask_ptr,
 	k = cpumask_bits(new_mask);
 	return compat_get_bitmap(k, user_mask_ptr, len * 8);
 }
+EXPORT_SYMBOL_GPL(compat_get_user_cpu_mask);
 
 COMPAT_SYSCALL_DEFINE3(sched_setaffinity, compat_pid_t, pid,
 		       unsigned int, len,
@@ -927,6 +928,7 @@ long compat_get_bitmap(unsigned long *mask, const compat_ulong_t __user *umask,
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(compat_get_bitmap);
 
 long compat_put_bitmap(compat_ulong_t __user *umask, unsigned long *mask,
 		       unsigned long bitmap_size)
@@ -967,6 +969,7 @@ long compat_put_bitmap(compat_ulong_t __user *umask, unsigned long *mask,
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(compat_put_bitmap);
 
 void
 sigset_from_compat(sigset_t *set, const compat_sigset_t *compat)
-- 
1.8.1
