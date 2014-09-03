From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH net-next 2/2] net: exit busy loop when another process
 is runnable
Date: Wed, 03 Sep 2014 09:21:25 +0300
Message-ID: <5406B365.5040604@linux.intel.com>
References: <1408608310-13579-1-git-send-email-jasowang@redhat.com>	 <1408608310-13579-2-git-send-email-jasowang@redhat.com>	 <1408683665.5648.69.camel@marge.simpson.net>	 <20140822073653.GA7372@gmail.com> <53F70887.8030602@redhat.com> <1408716976.5604.18.camel@edumazet-glaptop2.roam.corp.google.com> <53FB3715.7070009@linux.intel.com> <53FC3466.8000304@redhat.com> <5404186E.4090409@linux.intel.com> <54053AF8.6070907@redhat.com> <54055D9F.7000108@linux.intel.com> <54056459.4060100@redhat.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54056459.4060100@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/09/2014 09:31, Jason Wang wrote:
> On 09/02/2014 02:03 PM, Eliezer Tamir wrote:
>> On 02/09/2014 06:35, Jason Wang wrote:
>>> Not sure whether this method will scale considering thousands of sockets
>>> and processes.
>> There may be millions of sockets, but in most cases only a handful of
>> device queues per CPU to busy poll on. I have tested the epoll rfc
>> code with hundreds of thousands of sockets and one or two device
>> queues and is scales pretty well.
>>
>> The part I don't like in that code is the cumbersome mechanism I used
>> to track the socket -> queue relationship. I think that if I had more
>> time to work on it, I would instead look into extending the epoll
>> interface so that libevent can tell the kernel what it wants, instead
>> of having the busypoll code try and learn it.
> 
> I'd like to have a look at this rfc. Could you please give me a pointer?
> I've done a quick search on kernel mailing list but didn't find it.

https://lkml.org/lkml/2013/8/21/192

Cheers,
Eliezer
