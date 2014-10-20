From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet : stmicro: fixed power suspend and
 resume failure in stmmac driver
Date: Mon, 20 Oct 2014 11:36:54 -0400 (EDT)
Message-ID: <20141020.113654.1064324807051701300.davem@davemloft.net>
References: <20141001.134508.1301867654128829684.davem@davemloft.net>
	<543F88AE.2020702@st.com>
	<CAPig_t=Dguhw8jmAX_KvMrB9ZjL1POB+7jrdBmwpvTzjasKD1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, adi-linux-docs@lists.sourceforge.net
To: hliang1025@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPig_t=Dguhw8jmAX_KvMrB9ZjL1POB+7jrdBmwpvTzjasKD1w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hao Liang <hliang1025@gmail.com>
Date: Mon, 20 Oct 2014 16:55:08 +0800

> I can't quite seize David's meaing whether the ->mac->xxx should
> inside the lock or outside the lock.  In my opinion, the ->mac->xxx
> calls did not operate any shared data or struct. The calls just
> control the hardware by write data to registers.  So ->mac->xxx
> calls can be removed from lock.

If you make a decision to program the hardware in a certain way, you
must make sure that hardware programming operation occurs atomically.

This could be because it takes multiple register writes to perform
the operation and they are dependent upon eachother, or you are
makeing multiple modifications which must occur in a certain
sequence.

If you allow these ->mac->xxx calls to run in parallel with eachother
I guarantee it will cause problems.

Stop brushing it off as a non-issue, unless you want your driver
to mysteriously not work when the race is triggered.
