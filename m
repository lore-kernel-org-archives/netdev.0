From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 09/14] resource limits: track highwater mark of locked
	memory
Date: Fri, 15 Jul 2016 17:14:08 +0200
Message-ID: <20160715151408.GA32317@redhat.com>
References: <1468578983-28229-1-git-send-email-toiwoton@gmail.com> <1468578983-28229-10-git-send-email-toiwoton@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Tony Luck <tony.luck@intel.com>,
        Fenghua Yu <fenghua.yu@intel.com>, Paolo Bonzini <pbonzini@redhat.com>,
        Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
        Alexander Graf <agraf@suse.com>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>,
        Hal Rosenstock <hal.rosenstock@gmail.com>,
        Mike Marciniszyn <mike.marciniszyn@intel.com>,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Christian Benvenuti <benve@cisco.com>,
        Dave Goodell <dgoodell@cisco.com>, Sudeep Dutt <sudeep.dutt@intel.com>,
        Ashutosh Dixit <ashutosh.dixit@intel.com>,
        Alex Williamson <alex.williamson@redhat.com>,
        Alexei Starovoitov
To: Topi Miettinen <toiwoton@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
Content-Disposition: inline
In-Reply-To: <1468578983-28229-10-git-send-email-toiwoton@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 07/15, Topi Miettinen wrote:
>
> Track maximum size of locked memory, to be able to configure
> RLIMIT_MEMLOCK resource limits. The information is available
> with taskstats and cgroupstats netlink socket.

So I personally still dislike the very idea of this series... but I won't
argue if you convince maintainers.

> @@ -2020,6 +2020,10 @@ static int acct_stack_growth(struct vm_area_struct *vma, unsigned long size, uns
>  		return -ENOMEM;
>  
>  	update_resource_highwatermark(RLIMIT_STACK, actual_size);
> +	if (vma->vm_flags & VM_LOCKED)
> +		update_resource_highwatermark(RLIMIT_MEMLOCK,
> +					      (mm->locked_vm + grow) <<
> +					      PAGE_SHIFT);

Btw this is not right. The same for the previous patch which tracks
RLIMIT_STACK. The "current" task can debugger/etc.

Yes, yes, this just reminds that the whole rlimit logic in this path
is broken but still...

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
