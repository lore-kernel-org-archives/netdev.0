From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] x86/asm: Don't use rbp as temp register in
 csum_partial_copy_generic()
Date: Thu, 4 May 2017 15:56:49 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFE581C@AcuExch.aculab.com>
References: <4b03a961efda5ec9bfe46b7b9c9ad72d1efad343.1493909486.git.jpoimboe@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Andrey Konovalov <andreyknvl@google.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Vlad Yasevich <vyasevich@gmail.com>,
        "Neil Horman" <nhorman@tuxdriver.com>,
        "David S . Miller" <davem@davemloft.net>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        "Kostya Serebryany" <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>,
        "Eric Dumazet" <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
To: 'Josh Poimboeuf' <jpoimboe@redhat.com>,
        "x86@kernel.org" <x86@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4b03a961efda5ec9bfe46b7b9c9ad72d1efad343.1493909486.git.jpoimboe@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Josh Poimboeuf
> Sent: 04 May 2017 15:52
> Andrey Konovalov reported the following warning while fuzzing the kernel
> with syzkaller:
> 
>   WARNING: kernel stack regs at ffff8800686869f8 in a.out:4933 has bad 'bp' value c3fc855a10167ec0
> 
> The unwinder dump revealed that rbp had a bad value when an interrupt
> occurred in csum_partial_copy_generic().
> 
> That function saves rbp on the stack and then overwrites it, using it as
> a scratch register.  That's problematic because it breaks stack traces
> if an interrupt occurs in the middle of the function.

Does gcc guarantee not to use bp as a scratch register in leaf functions?

	David
