From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 1/1] NetLabel: add audit support for configuration changes
Date: Thu, 28 Sep 2006 15:50:42 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0609281547060.28120@d.namei>
References: <20060928180326.896170000@hp.com> <20060928180337.570612000@hp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-audit@redhat.com,
	Eric Paris <eparis@redhat.com>, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:13022 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1030363AbWI1Tuo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 15:50:44 -0400
To: Paul Moore <paul.moore@hp.com>,
	"David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060928180337.570612000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> +struct audit_buffer *netlbl_audit_start_common(int type, u32 secid)

> +	if (current->mm) {
> +		down_read(&current->mm->mmap_sem);
> +		vma = current->mm->mmap;
> +		while (vma) {
> +			if ((vma->vm_flags & VM_EXECUTABLE) &&
> +			    vma->vm_file) {
> +				audit_log_d_path(audit_buf,
> +						 " exe=",
> +						 vma->vm_file->f_dentry,
> +						 vma->vm_file->f_vfsmnt);
> +				break;
> +			}
> +			vma = vma->vm_next;
> +		}
> +		up_read(&current->mm->mmap_sem);


Suggestion for the future: I think it'd be wortwhile consolidating this 
with the code in audit_log_task_info().

In any case, the patch looks fine to me.

Acked-by: James Morris <jmorris@namei.org>



- James
-- 
James Morris
<jmorris@namei.org>
