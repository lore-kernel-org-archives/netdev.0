From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH] unix: fix use-after-free with unix_dgram_poll()
Date: Fri, 02 Oct 2015 15:50:08 -0400
Message-ID: <560EDFF0.9080108@akamai.com>
References: <20151002191039.9124420ED@prod-mail-relay10.akamai.com> <871tdd3w5s.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, minipli@googlemail.com,
	normalperson@yhbt.net, eric.dumazet@gmail.com,
	viro@zeniv.linux.org.uk, davidel@xmailserver.org,
	dave@stgolabs.net, olivier@mauras.ch, pageexec@freemail.hu,
	torvalds@linux-foundation.org, peterz@infradead.org
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <871tdd3w5s.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/02/2015 03:30 PM, Rainer Weikusat wrote:
> Jason Baron <jbaron@akamai.com> writes:
>> From: Jason Baron <jbaron@akamai.com>
>>
>> The unix_dgram_poll() routine calls sock_poll_wait() not only for the wait
>> queue associated with the socket s that we've called poll() on, but it also
>> calls sock_poll_wait() for a remote peer socket's wait queue, if it's connected.
>> Thus, if we call poll()/select()/epoll() for the socket s, there are then
>> a couple of code paths in which the remote peer socket s2 and its associated
>> peer_wait queue can be freed before poll()/select()/epoll() have a chance
>> to remove themselves from this remote peer socket s2's wait queue.
> 
> [...]
> 
>> This works because we will continue to get POLLOUT wakeups from
>> unix_write_space(), which is called via sock_wfree().
> 
> As pointed out in my original comment, this doesn't work (as far as I
> can/ could tell) because it will only wake up sockets which had a chance
> to enqueue datagrams to the queue of the receiving socket as only
> skbuffs enqueued there will be consumed. A socket which is really
> waiting for space in the receiving queue won't ever be woken up in this
> way.

Ok, good point. I was hoping to avoid a more complex approach here. I think
then that the patch I posted in the previous thread on this would address
this concern. I will post it for review.

> 
> Further, considering that you're demonstrably not interested in
> debugging and fixing this issue (as you haven't even bothered to post
> one of the test programs you claim to have), I'm beginning to wonder why
> this tripe is being sent to me at all --- it's not "git on autopilot"
> this time as someone took the time to dig up my current e-mail address
> as the one in the original commit is not valid anymore. Could you please
> refrain from such exercises in future unless a discussion is actually
> intended?
> 
> 

Just trying to help fix this.

Thanks,

-Jason
