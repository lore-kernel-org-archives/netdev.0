From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] NetLabel: add audit support for configuration
 changes
Date: Thu, 28 Sep 2006 14:51:56 -0700 (PDT)
Message-ID: <20060928.145156.110116847.davem@davemloft.net>
References: <20060928180326.896170000@hp.com>
	<20060928180337.570612000@hp.com>
	<Pine.LNX.4.64.0609281547060.28120@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, netdev@vger.kernel.org, linux-audit@redhat.com,
	eparis@redhat.com, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:45979
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161182AbWI1Vvx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 17:51:53 -0400
To: jmorris@namei.org
In-Reply-To: <Pine.LNX.4.64.0609281547060.28120@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Thu, 28 Sep 2006 15:50:42 -0400 (EDT)

> 
> > +struct audit_buffer *netlbl_audit_start_common(int type, u32 secid)
> 
> > +	if (current->mm) {
> > +		down_read(&current->mm->mmap_sem);
> > +		vma = current->mm->mmap;
> > +		while (vma) {
> > +			if ((vma->vm_flags & VM_EXECUTABLE) &&
> > +			    vma->vm_file) {
> > +				audit_log_d_path(audit_buf,
> > +						 " exe=",
> > +						 vma->vm_file->f_dentry,
> > +						 vma->vm_file->f_vfsmnt);
> > +				break;
> > +			}
> > +			vma = vma->vm_next;
> > +		}
> > +		up_read(&current->mm->mmap_sem);
> 
> 
> Suggestion for the future: I think it'd be wortwhile consolidating this 
> with the code in audit_log_task_info().
> 
> In any case, the patch looks fine to me.
> 
> Acked-by: James Morris <jmorris@namei.org>

Applied, thanks a lot.
