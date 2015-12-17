From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_unix: Revert 'lock_interruptible' in stream receive
 code
Date: Thu, 17 Dec 2015 15:34:41 -0500 (EST)
Message-ID: <20151217.153441.1336096182651045503.davem@davemloft.net>
References: <877fke6tqi.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: rweikusat@mobileactivedefense.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <877fke6tqi.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Date: Wed, 16 Dec 2015 20:09:25 +0000

> With b3ca9b02b00704053a38bfe4c31dbbb9c13595d0, the AF_UNIX SOCK_STREAM
> receive code was changed from using mutex_lock(&u->readlock) to
> mutex_lock_interruptible(&u->readlock) to prevent signals from being
> delayed for an indefinite time if a thread sleeping on the mutex
> happened to be selected for handling the signal. But this was never a
> problem with the stream receive code (as opposed to its datagram
> counterpart) as that never went to sleep waiting for new messages with the
> mutex held and thus, wouldn't cause secondary readers to block on the
> mutex waiting for the sleeping primary reader. As the interruptible
> locking makes the code more complicated in exchange for no benefit,
> change it back to using mutex_lock.
> 
> Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>

Applied, thanks Rainer.
