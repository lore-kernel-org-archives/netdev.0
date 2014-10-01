From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet : stmicro: fixed power suspend and
 resume failure in stmmac driver
Date: Wed, 01 Oct 2014 13:45:08 -0400 (EDT)
Message-ID: <20141001.134508.1301867654128829684.davem@davemloft.net>
References: <1412056534-7995-1-git-send-email-hliang1025@gmail.com>
	<20140930.151056.950254777090461575.davem@davemloft.net>
	<CAPig_t=oA6BuAt77DDsLqrtRBDbV_vsoAxM31XxLjkAFpYG1-Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, adi-linux-docs@lists.sourceforge.net
To: hliang1025@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPig_t=oA6BuAt77DDsLqrtRBDbV_vsoAxM31XxLjkAFpYG1-Q@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hao Liang <hliang1025@gmail.com>
Date: Wed, 1 Oct 2014 14:08:28 +0800

> I double-check my patch and the ->mac->xxx calls are still under the lock.
> I think that lock is trying to protect priv struct and related data, so i
> just remove some functions have no bearing on priv struct.

It's preventing parallel invocations of the ->mac->xxx calls.

The other instances are in device open/close, where RTNL semaphore is
held, and no other code paths in the driver can be active.

You need the lock.
