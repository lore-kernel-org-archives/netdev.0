From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 1/1] NetLabel: add audit support for configuration
	changes
Date: Thu, 28 Sep 2006 16:04:58 -0400
Message-ID: <451C2AEA.7050608@hp.com>
References: <20060928180326.896170000@hp.com> <20060928180337.570612000@hp.com>
	<Pine.LNX.4.64.0609281547060.28120@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com,
	"David S. Miller" <davem@davemloft.net>, selinux@tycho.nsa.gov
Return-path: <linux-audit-bounces@redhat.com>
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0609281547060.28120@d.namei>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

James Morris wrote:
>>+struct audit_buffer *netlbl_audit_start_common(int type, u32 secid)
> 
> 
>>+	if (current->mm) {
>>+		down_read(&current->mm->mmap_sem);
>>+		vma = current->mm->mmap;
>>+		while (vma) {
>>+			if ((vma->vm_flags & VM_EXECUTABLE) &&
>>+			    vma->vm_file) {
>>+				audit_log_d_path(audit_buf,
>>+						 " exe=",
>>+						 vma->vm_file->f_dentry,
>>+						 vma->vm_file->f_vfsmnt);
>>+				break;
>>+			}
>>+			vma = vma->vm_next;
>>+		}
>>+		up_read(&current->mm->mmap_sem);
> 
> 
> 
> Suggestion for the future: I think it'd be wortwhile consolidating this 
> with the code in audit_log_task_info().

Agreed, in fact, as I suspect you have already noticed, this was ripped
right from that function.  It was private to kernel/auditsc.c making it
offlimits, but I would have gladly used it instead; making
audit_log_task_info() public seemed like something that was beyond this
NetLabel specific patch.

> In any case, the patch looks fine to me.
> 
> Acked-by: James Morris <jmorris@namei.org>

Thanks.

-- 
paul moore
linux security @ hp
