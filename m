From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: Fix type of local variable in stmmac_xmit
Date: Fri, 04 Mar 2016 14:31:10 -0500 (EST)
Message-ID: <20160304.143110.200519699910396294.davem@davemloft.net>
References: <1457075944-6959-1-git-send-email-a.hajda@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	b.zolnierkie@samsung.com, m.szyprowski@samsung.com,
	linux-kernel@vger.kernel.org
To: a.hajda@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457075944-6959-1-git-send-email-a.hajda@samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrzej Hajda <a.hajda@samsung.com>
Date: Fri, 04 Mar 2016 08:19:04 +0100

> Variable entry holds result of jumbo_frm callback. It can be negative,
> so the variable should be signed. The patch changes also type of related
> first_entry variable to make code compact and coherent.
> 
> The problem has been detected using patch
> scripts/coccinelle/tests/unsigned_lesser_than_zero.cocci.
> 
> Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>

Actually, this only papers over a much deeper problem.

You cannot mix continually incrementing indexes with negative
return values.

You simply can't.

Because after enough traffic the legitimate indexes will be negative
integer values, so this jumbo index test would alway trigger.

A better fix is needed for this.  ->jumbo_frm() cannot return a value
that is interpreted both as an index as well as an error code.  The
dual signalling between these two values is simply impossible because
one the whole value space of a 32-bit integer is also a valid index.
