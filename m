From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH 1/6] ebpf: add a seccomp program type
Date: Wed, 9 Sep 2015 09:37:51 -0700
Message-ID: <CAGXu5jJVNfBZ1ugmpA3FCnG4++EPLfRhjSNBi3TtA0xGK=fzsg@mail.gmail.com>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com>
	<1441382664-17437-2-git-send-email-tycho.andersen@canonical.com>
	<CAGXu5j+9YvL6XzX=x8krZbdJXFpe-3FuMu=hAZX9Ew=hYyuK7Q@mail.gmail.com>
	<20150904210615.GR26679@smitten>
	<CAGXu5jKGBuD15KBfXKoYbGB40cNsbh=Dz8GM=bmUL-oECRhzxA@mail.gmail.com>
	<20150909155035.GA26679@smitten>
	<20150909160744.GA3526@Alexeis-MBP-2.westell.com>
	<55F059C7.9070105@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Tycho Andersen <tycho.andersen@canonical.com>,
	Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:35615 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754519AbbIIQhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 12:37:52 -0400
Received: by ioiz6 with SMTP id z6so28775863ioi.2
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 09:37:51 -0700 (PDT)
In-Reply-To: <55F059C7.9070105@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 9, 2015 at 9:09 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 09/09/2015 06:07 PM, Alexei Starovoitov wrote:
>>
>> On Wed, Sep 09, 2015 at 09:50:35AM -0600, Tycho Andersen wrote:
>
> [...]
>>>
>>> Thoughts?
>>
>>
>> Please do not add any per-instruction hacks. None of them are
>> necessary. Classic had to do extra ugly checks in seccomp only
>> because verifier wasn't flexible enough.
>> If you don't want to see any BPF_CALL in seccomp, just have
>> empty get_func_proto() callback for BPF_PROG_TYPE_SECCOMP
>> and verifier will reject all calls.
>> Currently we have only two non-generic instrucitons
>> LD_ABS and LD_IND that are avaialable for sockets/TC only,
>> because these are legacy instructions and we had to make
>> exceptions for them.
>
> Yep, +1.

Hrmpf. This adds to the cognitive load for accepting this patch
series. :P Now I have to convince myself that there is no additional
exposure to seccomp by using the entire set of eBPF instructions.
While I'm pretty sure it'll be fine, I really don't want to risk being
wrong and opening a hole here. I will spend some time looking at the
new eBPF instructions...

-Kees

-- 
Kees Cook
Chrome OS Security
