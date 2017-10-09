From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/core: Fix BUG to BUG_ON conditionals.
Date: Mon, 09 Oct 2017 16:17:08 -0700 (PDT)
Message-ID: <20171009.161708.963726434970115075.davem@davemloft.net>
References: <20171009171540.lgmk2slq3bdrptxk@ast-mbp.dhcp.thefacebook.com>
        <20171009202633.ep5pbi2tlg7dqidz@sasha-lappy>
        <20171009230618.e5gla2iuqwmndkig@ast-mbp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.levin@verizon.com, devtimhansen@gmail.com,
        willemb@google.com, edumazet@google.com, soheil@google.com,
        pabeni@redhat.com, elena.reshetova@intel.com, tom@quantonium.net,
        Jason@zx2c4.com, fw@strlen.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: alexei.starovoitov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171009230618.e5gla2iuqwmndkig@ast-mbp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Mon, 9 Oct 2017 16:06:20 -0700

>> For these archs, wouldn't it then be more efficient to use BUG_ON
>> rather than BUG()?
> 
> why more efficient? any data to prove that?

It can completely eliminate a branch.

For example on powerpc if you use BUG() then the code generated is:

	test condition
	branch_not_true	1f
	unconditional_trap
1:

Whereas with BUG_ON() it's just:

	test condition
	trap_if_true

Which is a lot better even when the branches in the first case are
well predicted.
