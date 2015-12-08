From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] fix inverted test in __skb_recv_datagram
Date: Tue, 08 Dec 2015 14:46:36 +0000
Message-ID: <87io4980c3.fsf@doppelsaurus.mobileactivedefense.com>
References: <20151206.233038.1580536748391971635.davem@davemloft.net>
	<874mft7sur.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<87vb8925vx.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<20151207.222827.1680789119862020474.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151207.222827.1680789119862020474.davem@davemloft.net> (David
	Miller's message of "Mon, 07 Dec 2015 22:28:27 -0500 (EST)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:
> From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
> Date: Mon, 07 Dec 2015 23:30:58 +0000
>
>> As the kernel generally uses negated error numbers, *err needs to be
>> compared with -EAGAIN (d'oh).
>> 
>> Signed-off-by: Rainer Weikusat <rweikusat@mobileactivedefense.com>
>> Fixes: ea3793ee29d3
>
> Improperly formatted Fixes: tag, you must also include the commit
> header line, in parenthesis and double quotes, after the SHA_ID.
>
> Futhermore this is the wrong SHA_ID.

https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=ea3793ee29d3

displays the commit I was referring to, namely, the one containing this

+ timeo = sock_rcvtimeo(sk, flags & MSG_DONTWAIT);
+
+ do {
+ skb = __skb_try_recv_datagram(sk, flags, peeked, off, err,
+ &last);
+ if (skb)
+ return skb;
+
+ if (*err != EAGAIN)
+ break;
+ } while (timeo &&
+ !__skb_wait_for_more_packets(sk, err, &timeo, last));

which added the inverted test, IOW, if this is the wrong hash, I have no
idea what the right one could be. I'll resubmit this with the 'one line
summary' added. After noticing the issue around 23:10 UK time yesterday,
I was in a bit of a hurry and stopped reading the 'Fixes' text in
SubmittingPatches after the "with the first 12 characters".
