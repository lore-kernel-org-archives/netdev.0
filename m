From: syrine tlili <syrine.tl@gmail.com>
Subject: Re: Null pointers linux3.8-rc6
Date: Thu, 7 Feb 2013 20:43:42 +0100
Message-ID: <CAETb2JOYSFJ2FqWhFjN6FsTugcWD1Dg54Y6DvgmtT2wD4v2U-Q@mail.gmail.com>
References: <CAETb2JPm9rL=ParaVWhhpxE0gEzgw3+4ishf6sHOfm-Khwcw4Q@mail.gmail.com>
	<20130207.143913.290469260544108221.davem@davemloft.net>
Reply-To: syrine.tl@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:35589 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422639Ab3BGTnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 14:43:43 -0500
Received: by mail-qc0-f170.google.com with SMTP id d42so1148417qca.29
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2013 11:43:42 -0800 (PST)
In-Reply-To: <20130207.143913.290469260544108221.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patches for null pointer check

diff --git a/a/arch/x86/platform/efi/efi.c b/b/arch/x86/platform/efi/efi.c
index 77cf009..e64c3f4 100644
--- a/a/arch/x86/platform/efi/efi.c
+++ b/b/arch/x86/platform/efi/efi.c
@@ -924,6 +924,8 @@ void __init efi_enter_virtual_mode(void)
 		new_memmap = krealloc(new_memmap,
 				      (count + 1) * memmap.desc_size,
 				      GFP_KERNEL);
+		if (!new_memmap)
+			return -ENOMEM;
 		memcpy(new_memmap + (count * memmap.desc_size), md,
 		       memmap.desc_size);
 		count++;
diff --git a/a/fs/ceph/mdsmap.c b/b/fs/ceph/mdsmap.c
index 73b7d44..d04ab8b 100644
--- a/a/fs/ceph/mdsmap.c
+++ b/b/fs/ceph/mdsmap.c
@@ -132,6 +132,8 @@ struct ceph_mdsmap *ceph_mdsmap_decode(void **p, void *end)
 				m->m_info[mds].export_targets =
 					kcalloc(num_export_targets, sizeof(u32),
 						GFP_NOFS);
+				if (m->m_info[mds].export_targets == NULL)
+					goto badmem;
 				for (j = 0; j < num_export_targets; j++)
 					m->m_info[mds].export_targets[j] =
 					       ceph_decode_32(&pexport_targets);
diff --git a/a/drivers/isdn/mISDN/fsm.c b/b/drivers/isdn/mISDN/fsm.c
index 26477d4..07040b2 100644
--- a/a/drivers/isdn/mISDN/fsm.c
+++ b/b/drivers/isdn/mISDN/fsm.c
@@ -34,6 +34,8 @@ mISDN_FsmNew(struct Fsm *fsm,

 	fsm->jumpmatrix = kzalloc(sizeof(FSMFNPTR) * fsm->state_count *
 				  fsm->event_count, GFP_KERNEL);
+	if (!fsm->jumpmatrix)
+		return -ENOMEM;

 	for (i = 0; i < fncount; i++)
 		if ((fnlist[i].state >= fsm->state_count) ||
diff --git a/a/drivers/scsi/megaraid.c b/b/drivers/scsi/megaraid.c
index 9504ec0..37b915f 100644
--- a/a/drivers/scsi/megaraid.c
+++ b/b/drivers/scsi/megaraid.c
@@ -4437,6 +4437,8 @@ mega_internal_command(adapter_t *adapter,
megacmd_t *mc, mega_passthru *pthru)
 	memset(scb, 0, sizeof(scb_t));

 	sdev = kzalloc(sizeof(struct scsi_device), GFP_KERNEL);
+	if (!sdev)
+		goto err_out;
 	scmd->device = sdev;

 	memset(adapter->int_cdb, 0, sizeof(adapter->int_cdb));
@@ -4482,6 +4484,11 @@ mega_internal_command(adapter_t *adapter,
megacmd_t *mc, mega_passthru *pthru)
 	scsi_free_command(GFP_KERNEL, scmd);

 	return rval;
+
+err_out:
+	mutex_unlock(&adapter->int_mtx);
+	scsi_free_command(GFP_KERNEL, scmd);
+	return -ENOMEM;
 }



On Thu, Feb 7, 2013 at 8:39 PM, David Miller <davem@davemloft.net> wrote:
> From: syrine tlili <syrine.tl@gmail.com>
> Date: Thu, 7 Feb 2013 20:32:11 +0100
>
>> I also suggest a set of patches to fix the detected errors.
>
> Your patches are not useful because they have been corrupted by your
> email client.
