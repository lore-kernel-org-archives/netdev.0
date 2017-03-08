From: Laura Abbott <labbott@redhat.com>
Subject: Re: [net/bpf] 3051bf36c2 BUG: unable to handle kernel paging request
 at 0000a7cf
Date: Wed, 8 Mar 2017 15:55:39 -0800
Message-ID: <7af7bcc9-9115-be9f-2240-a022487e9b70@redhat.com>
References: <20170301125426.l4nf65rx4wahohyl@wfg-t540p.sh.intel.com>
 <20170302202338.ci6wwb3yzjmdy4n2@wfg-t540p.sh.intel.com>
 <58B88353.2010508@iogearbox.net>
 <CA+55aFy97mLPLb4WXmRn-xLMNt+bNkrb_vaBsh+HOMLLnKPv7Q@mail.gmail.com>
 <58C08535.3070000@iogearbox.net>
 <CAGXu5jLB_+47FEJYTYJ5u6-u+vOBpWo_0tWuiNKnGmuMjL-mMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>,
        Fengguang Wu <fengguang.wu@intel.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
        ast@fb.com, the arch/x86 maintainers <x86@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Kees Cook <keescook@chromium.org>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:36361 "EHLO
        mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750707AbdCIAWU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 19:22:20 -0500
Received: by mail-qk0-f178.google.com with SMTP id 1so95400197qkl.3
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 16:20:35 -0800 (PST)
In-Reply-To: <CAGXu5jLB_+47FEJYTYJ5u6-u+vOBpWo_0tWuiNKnGmuMjL-mMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/08/2017 02:36 PM, Kees Cook wrote:
> On Wed, Mar 8, 2017 at 2:27 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> [   28.474232] rodata_test: test data was not read only
>> [...]
> 
> In my tests so far, I've never been able to get rodata_test to fail
> (Qemu 2.5.0, Ubuntu). I'll retry with your .config and see if I can
> recheck under Qemu 2.7.1. Do you see these failures on real hardware?
> 
> -Kees
> 

FWIW, I'm seeing the same issue with qemu 2.6.2 and 2.8.0 on Fedora 24
and rawhide respectively. 

I also notice that CONFIG_X86_PAE is turned off in the defconfig. If
I set CONFIG_HIGHMEM_64G which turns on CONFIG_X86_PAE the problem
goes away. I can't tell if this is an indication of magically hiding
the TLB problem or if there is an issue with !X86_PAE invalidation.


Thanks,
Laura
