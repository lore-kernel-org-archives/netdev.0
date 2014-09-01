From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH net-next 2/2] net: exit busy loop when another process
 is runnable
Date: Mon, 01 Sep 2014 09:55:42 +0300
Message-ID: <5404186E.4090409@linux.intel.com>
References: <1408608310-13579-1-git-send-email-jasowang@redhat.com>	 <1408608310-13579-2-git-send-email-jasowang@redhat.com>	 <1408683665.5648.69.camel@marge.simpson.net>	 <20140822073653.GA7372@gmail.com> <53F70887.8030602@redhat.com> <1408716976.5604.18.camel@edumazet-glaptop2.roam.corp.google.com> <53FB3715.7070009@linux.intel.com> <53FC3466.8000304@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>,
	Mike Galbraith <umgwanakikbuti@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, Peter Zijlstra <peterz@infradead.org>,
	"Ingo Molnar jacob.e.keller@intel.com" <mingo@elte.hu>
To: Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:39177 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752012AbaIAGzt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Sep 2014 02:55:49 -0400
In-Reply-To: <53FC3466.8000304@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/08/2014 10:16, Jason Wang wrote:
> On 08/25/2014 09:16 PM, Eliezer Tamir wrote:
>> Here are my 2 cents:
>> I think Ingo's suggestion of only yielding to tasks with same or higher
>> priority makes sense.
> 
> I'm not sure I get your meaning. Do you mean calling yield_to() directly
> in sk_busy_loop?

Think about the case where two processes are busy polling on the
same CPU and the same device queue. Since busy polling processes
incoming packets on the queue from any process, this scenario works
well currently, and will not work at all when polling yields to other
processes that are of the same priority that are running on the same
CPU.

As a side note, there is a lot of room for improvement when two
processes on the same CPU want to busy poll on different device
queues.
The RFC code I published for epoll support showed one possible
way of solving this, but I'm sure that there are other possibilities.

Maybe the networking subsystem should maintain a list of device
queues that need busypolling and have a thread that would poll
all of them when there's nothing better to do.

I'm aware of similar work on busy polling on NVMe devices, so
maybe there should be a global busypoll thread for all devices
that support it.

BTW, I have someone inside Intel that wants to test future patches. Feel
free to send me patches for testing, even if they are not ready for
publishing yet.

Cheers,
Eliezer
