From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net, llc: Avoid undefined behaviour in
 llc_conn_ac_inc_vr_by_1()
Date: Sat, 25 Jun 2011 17:04:45 -0700 (PDT)
Message-ID: <20110625.170445.957364657527336185.davem@davemloft.net>
References: <alpine.LNX.2.00.1106260009530.23991@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jj@chaosbits.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1106260009530.23991@swampdragon.chaosbits.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jj@chaosbits.net>
Date: Sun, 26 Jun 2011 00:11:12 +0200 (CEST)

> Introduce a sequence point (;) between two writes to llc_sk(sk)->vR in
> net/llc/llc_c_ac.c:llc_conn_ac_inc_vr_by_1() so that the order in
> which the writes happen become well defined.
> 
> While the code may work fine now it may break at any time with a
> different compiler, a new version of current compiler or even just a
> different optimization level of the current compiler. Much better to
> clearly express what's intended in a way that guarantees the result.
> 
> Signed-off-by: Jesper Juhl <jj@chaosbits.net>

How about fixing the macro so that it doesn't have side effects
like this?

That's much better than a 6 line (improperly formatted, BTW) comment
every time someone tried to use that macros with an lvalue that isn't
a local variable.
