From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [net/bpf] 3051bf36c2 BUG: unable to handle kernel paging request
 at 0000a7cf
Date: Thu, 9 Mar 2017 14:10:46 +0100 (CET)
Message-ID: <alpine.DEB.2.20.1703091409080.3521@nanos>
References: <20170301125426.l4nf65rx4wahohyl@wfg-t540p.sh.intel.com> <20170302202338.ci6wwb3yzjmdy4n2@wfg-t540p.sh.intel.com> <58B88353.2010508@iogearbox.net> <CA+55aFy97mLPLb4WXmRn-xLMNt+bNkrb_vaBsh+HOMLLnKPv7Q@mail.gmail.com> <58C08535.3070000@iogearbox.net>
 <CAGXu5jLB_+47FEJYTYJ5u6-u+vOBpWo_0tWuiNKnGmuMjL-mMQ@mail.gmail.com> <7af7bcc9-9115-be9f-2240-a022487e9b70@redhat.com> <CAGXu5jLm3jbJoQAsBsTiiQGK1==JTnSkN_GLsuBGqFvAz5B3AQ@mail.gmail.com> <58C152F1.9090004@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Kees Cook <keescook@chromium.org>,
        Laura Abbott <labbott@redhat.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>,
        Fengguang Wu <fengguang.wu@intel.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
        ast@fb.com, the arch/x86 maintainers <x86@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <58C152F1.9090004@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 9 Mar 2017, Daniel Borkmann wrote:
> With regard to CPA_FLUSHTLB that Linus mentioned, when I investigated
> code paths in change_page_attr_set_clr(), I did see that CPA_FLUSHTLB
> was set each time we switched attrs and a cpa_flush_range() was
> performed (with the correct number of pages and cache set to 0). That
> would be a __flush_tlb_all() eventually.
> 
> Hmm, it indeed might seem likely that this could be an emulation bug.

Which variant of __flush_tlb_all() is used when the test fails?

Check for the following flags in /proc/cpuinfo: pge invpcid

Thanks,

	tglx
