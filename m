From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH RFC net-next] net: epoll support for busy poll
Date: Wed, 21 Aug 2013 18:09:06 +0300
Message-ID: <5214D812.3090906@linux.intel.com>
References: <20130821103954.30607.6819.stgit@ladj378.jer.intel.com> <1377093188.4226.108.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Eilon Greenstein <eilong@broadcom.com>,
	Amir Vadai <amirv@mellanox.com>,
	Willem de Bruijn <willemb@google.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377093188.4226.108.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 21/08/2013 16:53, Eric Dumazet wrote:
> On Wed, 2013-08-21 at 13:39 +0300, Eliezer Tamir wrote:
> 
>>
>> Instead of remembering the napi_id for all the sockets in an epoll,
>> we only track the first socket we see with any unique napi_id.
>> The rational for this is that while there may be many thousands of
>> sockets tracked by a single epoll, we expect to only see a handful
>> of unique napi_ids in most cases.
> 
> This looks buggy assumption to me.
> 
> We use epoll() with in the order of millions of fds per epoller, and
> typically one napi_id per cpu.
> 
> With your model, we would have to use nr_cpu epollers and make sure that
> sockets are properly placed on those epollers by their napi_ids.

There is no assumption here on how the user configures epoll.
All we are doing is reducing the list of sockets monitored
by an epoll instance to a smaller subset where each NAPI_ID
appears only once.

The user is free to have an epoll monitor sockets from queues
associated to any CPU.
