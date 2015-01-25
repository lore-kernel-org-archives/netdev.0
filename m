From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atheros/atlx: Simplify bit manipulations
Date: Sat, 24 Jan 2015 23:35:40 -0800 (PST)
Message-ID: <20150124.233540.192666118515975126.davem@davemloft.net>
References: <1422011212-30095-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux@rasmusvillemoes.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422011212-30095-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Date: Fri, 23 Jan 2015 12:06:52 +0100

> The code 'if (foo & X) foo &= ~X;' is semantically equivalent to
> simply 'foo &= ~X;', but gcc generates about four instructions for the
> former, one for the latter. Similarly, if X consists of a single bit,
> 'if (!(foo & X)) X |= X;' can be replaced by 'foo |= X;'.
> 
> In the atl2 case, gcc does know how to merge the new adjacent
> operations, so altogether this gives a nice little code size
> reduction of about 80 bytes.
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

I agree with the feedback given that these open-coded sequences should
be replaced with the appropriate PCI helpers instead of edited
further.
