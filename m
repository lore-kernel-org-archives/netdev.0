From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: eBPF verifier thoughts (Re: [PATCH v15 net-next 00/11] eBPF
 syscall, verifier, testsuite)
Date: Fri, 26 Sep 2014 15:26:40 -0700
Message-ID: <CAMEtUuzQF+3uWFWmj5nSdYoJfo0W2F0wkvoyc4pP--EH3O_jYA@mail.gmail.com>
References: <CALCETrVrHHxGo1RkPu+9LVnPo9XY9yYnJzg2ot0zOgoBspzbOQ@mail.gmail.com>
	<CAMEtUuyt9RASKZ4NeqK_OUYNN8QT6P20+kjcwywchur6QXSt0A@mail.gmail.com>
	<CALCETrXS5KBHm-3Fz031VFPpTHC_BDOLd_zNB6DjCidZa5-x2A@mail.gmail.com>
	<CAMEtUux-WFOGABTrWW=BGUstE=Zz6agXTGCGrRJtNXDfRmx-5A@mail.gmail.com>
	<CALCETrVLtJOYkHwsmwueZ7jsSgrNED564W+m4FmMZJZL-836mg@mail.gmail.com>
	<CAMEtUuxq7oNmDAHZ+1t4Vd-QhW6SV7eoM_juxXGEDJBF3Nfu6A@mail.gmail.com>
	<CALCETrWcmZVmRZARM_s9S-zZ4Xm_TcxRrzJWGwL0O9ySmVgr5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:53945 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755683AbaIZW0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 18:26:42 -0400
Received: by mail-la0-f47.google.com with SMTP id mc6so15086380lab.6
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 15:26:41 -0700 (PDT)
In-Reply-To: <CALCETrWcmZVmRZARM_s9S-zZ4Xm_TcxRrzJWGwL0O9ySmVgr5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 26, 2014 at 3:07 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> On Fri, Sep 26, 2014 at 3:03 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
>> On Fri, Sep 26, 2014 at 2:47 PM, Andy Lutomirski <luto@amacapital.net> wrote:
>>>
>>> Can't you just disallow the 1-byte write to the stack?
>>
>> of course not.
>> That would be extremely limiting to users.
>> Can you actually see yourself living with stack that only
>> allows 8-byte writes/reads?
>> The stack usage will increase a lot, since all char/short
>> stack variables will become 8-byte...
>
> How about requiring that sub-8-byte stack accesses only be to integer slots?

you mean to reject the sub-8-byte write early if it's going
into space where pointers were stored?
That will limit stack reuse.
gcc/llvm generate code where the same stack location
is used by different variables during life of the function.
So if I reject the write early, it will break otherwise valid
programs.
