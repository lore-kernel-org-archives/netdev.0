From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: bpf: undefined shift in __bpf_prog_run
Date: Fri, 4 Dec 2015 12:35:23 -0800
Message-ID: <20151204203522.GB64517@ast-mbp.thefacebook.com>
References: <20151204184333.GA42737@ast-mbp.thefacebook.com>
 <CACT4Y+YLV4scGXSFz=G3ACa-WE8VuT5wDGvPBV9D2Q+devxedA@mail.gmail.com>
 <20151204191013.GB45508@ast-mbp.thefacebook.com>
 <20151204.142651.968075964630586979.davem@davemloft.net>
 <CACT4Y+Y6vzvHuxk=o5Y_f2qDCGW30cAOCuyCeoLtj28Xh3G1dA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Alexei Starovoitov <ast@kernel.org>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>,
	Andrey Ryabinin <ryabinin.a.a@gmail.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACT4Y+Y6vzvHuxk=o5Y_f2qDCGW30cAOCuyCeoLtj28Xh3G1dA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 04, 2015 at 08:48:57PM +0100, Dmitry Vyukov wrote:
> 
> For example, a compiler can assume that result of left shift is larger
> or equal to first operand, which in turn can allow it to elide some
> bounds check in code, which in turn can lead to an exploit. I am not
> saying that this particular pattern is present in the code, what I
> want to say is that such undefined behaviors can lead to very
> unpredictable and unexpected consequences.

Within bpf it cannot.
shift is not used in any memory or bounds operations.
so reg <<= 1234 cannot be exploited.
