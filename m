From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 09/14] resource limits: track highwater mark of locked
	memory
Date: Mon, 18 Jul 2016 17:38:03 +0200
Message-ID: <20160718153802.GA31174@redhat.com>
References: <1468578983-28229-1-git-send-email-toiwoton@gmail.com> <1468578983-28229-10-git-send-email-toiwoton@gmail.com> <20160715151408.GA32317@redhat.com> <5c43bc33-6625-ceb7-e96e-adf7df5b642c@gmail.com>
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
In-Reply-To: <5c43bc33-6625-ceb7-e96e-adf7df5b642c@gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 07/15, Topi Miettinen wrote:
>
> On 07/15/16 15:14, Oleg Nesterov wrote:
> >
> > Btw this is not right. The same for the previous patch which tracks
> > RLIMIT_STACK. The "current" task can debugger/etc.
>
> acct_stack_growth() is called from expand_upwards() and
> expand_downwards(). They call security_mmap_addr() and the various LSM
> implementations also use current task in the checks. Are these also not
> right?

Just suppose that the stack grows because you read/write to /proc/pid/mem.

> > Yes, yes, this just reminds that the whole rlimit logic in this path
> > is broken but still...
>
> I'd be happy to fix the logic with a separate prerequisite patch and
> then use the right logic for this patch, but I'm not sure I know how.
> Could you elaborate a bit?

If only I Knew how to fix this ;) I mean, if only I could suggest a
simple fix. Because IMHO we do not really care, rlimts are obsolete.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
