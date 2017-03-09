From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net/bpf] 3051bf36c2 BUG: unable to handle kernel paging request
 at 0000a7cf
Date: Thu, 09 Mar 2017 14:25:58 +0100
Message-ID: <58C157E6.1010909@iogearbox.net>
References: <20170301125426.l4nf65rx4wahohyl@wfg-t540p.sh.intel.com> <20170302202338.ci6wwb3yzjmdy4n2@wfg-t540p.sh.intel.com> <58B88353.2010508@iogearbox.net> <CA+55aFy97mLPLb4WXmRn-xLMNt+bNkrb_vaBsh+HOMLLnKPv7Q@mail.gmail.com> <58C08535.3070000@iogearbox.net> <CAGXu5jLB_+47FEJYTYJ5u6-u+vOBpWo_0tWuiNKnGmuMjL-mMQ@mail.gmail.com> <7af7bcc9-9115-be9f-2240-a022487e9b70@redhat.com> <CAGXu5jLm3jbJoQAsBsTiiQGK1==JTnSkN_GLsuBGqFvAz5B3AQ@mail.gmail.com> <58C152F1.9090004@iogearbox.net> <alpine.DEB.2.20.1703091409080.3521@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kees Cook <keescook@chromium.org>,
        Laura Abbott <labbott@redhat.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>,
        Fengguang Wu <fengguang.wu@intel.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
        ast@fb.com, the arch/x86 maintainers <x86@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.20.1703091409080.3521@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/09/2017 02:10 PM, Thomas Gleixner wrote:
> On Thu, 9 Mar 2017, Daniel Borkmann wrote:
>> With regard to CPA_FLUSHTLB that Linus mentioned, when I investigated
>> code paths in change_page_attr_set_clr(), I did see that CPA_FLUSHTLB
>> was set each time we switched attrs and a cpa_flush_range() was
>> performed (with the correct number of pages and cache set to 0). That
>> would be a __flush_tlb_all() eventually.
>>
>> Hmm, it indeed might seem likely that this could be an emulation bug.
>
> Which variant of __flush_tlb_all() is used when the test fails?
>
> Check for the following flags in /proc/cpuinfo: pge invpcid

I added the following and booted with both variants:

printk("X86_FEATURE_PGE:%u\n",     static_cpu_has(X86_FEATURE_PGE));
printk("X86_FEATURE_INVPCID:%u\n", static_cpu_has(X86_FEATURE_INVPCID));

"-cpu host" gives:

[    8.326117] X86_FEATURE_PGE:1
[    8.326381] X86_FEATURE_INVPCID:1

"-cpu kvm64" gives:

[    8.517069] X86_FEATURE_PGE:1
[    8.517393] X86_FEATURE_INVPCID:0

Thanks,
Daniel
