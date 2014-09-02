From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 2/2] net: exit busy loop when another process
 is runnable
Date: Tue, 02 Sep 2014 11:35:20 +0800
Message-ID: <54053AF8.6070907@redhat.com>
References: <1408608310-13579-1-git-send-email-jasowang@redhat.com>	 <1408608310-13579-2-git-send-email-jasowang@redhat.com>	 <1408683665.5648.69.camel@marge.simpson.net>	 <20140822073653.GA7372@gmail.com> <53F70887.8030602@redhat.com> <1408716976.5604.18.camel@edumazet-glaptop2.roam.corp.google.com> <53FB3715.7070009@linux.intel.com> <53FC3466.8000304@redhat.com> <5404186E.4090409@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>,
	Mike Galbraith <umgwanakikbuti@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, Peter Zijlstra <peterz@infradead.org>,
	"Ingo Molnar jacob.e.keller@intel.com" <mingo@elte.hu>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14788 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751832AbaIBDfz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Sep 2014 23:35:55 -0400
In-Reply-To: <5404186E.4090409@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2014 02:55 PM, Eliezer Tamir wrote:
> On 26/08/2014 10:16, Jason Wang wrote:
>> On 08/25/2014 09:16 PM, Eliezer Tamir wrote:
>>> Here are my 2 cents:
>>> I think Ingo's suggestion of only yielding to tasks with same or higher
>>> priority makes sense.
>> I'm not sure I get your meaning. Do you mean calling yield_to() directly
>> in sk_busy_loop?
> Think about the case where two processes are busy polling on the
> same CPU and the same device queue. Since busy polling processes
> incoming packets on the queue from any process, this scenario works
> well currently,

I see, but looks like we can simply do this by exiting the busy loop
when ndo_busy_poll() finds something but not for current socket?
>  and will not work at all when polling yields to other
> processes that are of the same priority that are running on the same
> CPU.

So yielding has its limitation, we need let scheduler to do the choice
instead.
>
> As a side note, there is a lot of room for improvement when two
> processes on the same CPU want to busy poll on different device
> queues.
> The RFC code I published for epoll support showed one possible
> way of solving this, but I'm sure that there are other possibilities.
>
> Maybe the networking subsystem should maintain a list of device
> queues that need busypolling and have a thread that would poll
> all of them when there's nothing better to do.

Not sure whether this method will scale considering thousands of sockets
and processes.
>
> I'm aware of similar work on busy polling on NVMe devices, so
> maybe there should be a global busypoll thread for all devices
> that support it.
>
> BTW, I have someone inside Intel that wants to test future patches. Feel
> free to send me patches for testing, even if they are not ready for
> publishing yet.
>
> Cheers,
> Eliezer

Ok, will do it, thanks a lot.
