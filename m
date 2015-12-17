From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] af_unix: Revert 'lock_interruptible' in stream receive code
Date: Thu, 17 Dec 2015 15:28:21 +0000
Message-ID: <87a8p92iy2.fsf@doppelsaurus.mobileactivedefense.com>
References: <877fke6tqi.fsf@doppelsaurus.mobileactivedefense.com>
	<56727EE9.5020805@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56727EE9.5020805@stressinduktion.org> (Hannes Frederic Sowa's
	message of "Thu, 17 Dec 2015 10:22:49 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
> On 16.12.2015 21:09, Rainer Weikusat wrote:
>> With b3ca9b02b00704053a38bfe4c31dbbb9c13595d0, the AF_UNIX SOCK_STREAM
>> receive code was changed from using mutex_lock(&u->readlock) to
>> mutex_lock_interruptible(&u->readlock) to prevent signals from being
>> delayed for an indefinite time if a thread sleeping on the mutex
>> happened to be selected for handling the signal. But this was never a
>> problem with the stream receive code (as opposed to its datagram
>> counterpart) as that never went to sleep waiting for new messages with the
>> mutex held and thus, wouldn't cause secondary readers to block on the
>> mutex waiting for the sleeping primary reader. As the interruptible
>> locking makes the code more complicated in exchange for no benefit,
>> change it back to using mutex_lock.
>> 
>> Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>
>> ---
>> 
>> Considering that the datagram receive routine also doesn't go the sleep
>> with the mutex held anymore, the 37ab4fa7844a044dc21fde45e2a0fc2f3c3b6490
>> change to unix_autobind is now similarly purposeless.
>
> I wouldn't do this conversion, yet. There is still a deadlock lingering
> around which should be solved earlier:
>
> http://lists.openwall.net/netdev/2015/11/10/4
>
> Unfortunately I haven't found a good way how to solve it, yet.

Judging from the link, that's not related to the stream receive code.
