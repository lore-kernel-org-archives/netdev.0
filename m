From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] sh: add missing fpscr_values
Date: Wed, 2 Apr 2014 09:09:56 -0700
Message-ID: <CAMEtUuy_KZXmWAs6GkZe2HdJ_i0Go+FpJ09rA0AVg=dpWCevig@mail.gmail.com>
References: <1396407244-26771-1-git-send-email-ast@plumgrid.com>
	<20140402.084713.204716153605145333.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Paul Mundt <lethal@linux-sh.org>,
	kbuild test robot <fengguang.wu@intel.com>,
	linux-sh <linux-sh@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Kaz Kojima <kkojima@rr.iij4u.or.jp>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	linux-next@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20140402.084713.204716153605145333.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 2, 2014 at 5:47 AM, David Miller <davem@davemloft.net> wrote:
> From: Alexei Starovoitov <ast@plumgrid.com>
> Date: Tue,  1 Apr 2014 19:54:04 -0700
>
>> GCC on SuperH for the following program:
>> int foo(int i)
>> {
>>       static const void *table[2] = {
>>               [0] = &&label1,
>>               [1] = &&label2,
>>       };
>>       goto *table[i & 1];
>>
>>       label1:
>>               return 1;
>>       label2:
>>               return 2;
>> }
>> generates code:
>>       mov.l   .L9,r1
>>       mov     #1,r0
>>       rts
>>       lds.l   @r1+,fpscr
>> .L9:
>>       .long   __fpscr_values+4
>>
>> so kernel has to provide body of fpscr_values just like glibc does
>>
>> Fixes: bd4cf0ed331a ("net: filter: rework/optimize internal BPF interpreter's instruction set")
>> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>
> You guys really need to just fix the compiler, sorry.

agree.

To summarize:
according to Kaz:
"For sh2a, configuring gcc with --with-multilib-list=m2a,m2a-nofpu
 and specifying -m2a-nofpu during compiling kernel would work."

and as Geert pointed out we already have:
arch/sh/Makefile:
cflags-$(CONFIG_CPU_SH2A)               += $(call cc-option,-m2a,) \
                                           $(call cc-option,-m2a-nofpu,)

so no kernel changes needed and gcc just needs to be reconfigured.
