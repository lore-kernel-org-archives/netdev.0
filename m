From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] af_unix: Revert 'lock_interruptible' in stream receive
 code
Date: Thu, 17 Dec 2015 10:22:49 +0100
Message-ID: <56727EE9.5020805@stressinduktion.org>
References: <877fke6tqi.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Al Viro <viro@ZenIV.linux.org.uk>
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <877fke6tqi.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16.12.2015 21:09, Rainer Weikusat wrote:
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
> ---
> 
> Considering that the datagram receive routine also doesn't go the sleep
> with the mutex held anymore, the 37ab4fa7844a044dc21fde45e2a0fc2f3c3b6490
> change to unix_autobind is now similarly purposeless.

I wouldn't do this conversion, yet. There is still a deadlock lingering
around which should be solved earlier:

http://lists.openwall.net/netdev/2015/11/10/4

Unfortunately I haven't found a good way how to solve it, yet.

Thanks,
Hannes
