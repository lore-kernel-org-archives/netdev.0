From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v2 net-next] net: Add low-latency/polling support for
 UDP multicast
Date: Sun, 11 Aug 2013 10:59:39 +0300
Message-ID: <5207446B.4080003@linux.intel.com>
References: <5200A203.2090306@linux.intel.com>   <1375818663-12318-1-git-send-email-sbohrer@rgmadvisors.com>  <1375906946.4004.45.camel@edumazet-glaptop>  <52035AD9.30703@linux.intel.com> <1376006114.4004.141.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Shawn Bohrer <sbohrer@rgmadvisors.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	tomk@rgmadvisors.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40229 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752416Ab3HKH7n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Aug 2013 03:59:43 -0400
In-Reply-To: <1376006114.4004.141.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/08/2013 02:55, Eric Dumazet wrote:
> On Thu, 2013-08-08 at 11:46 +0300, Eliezer Tamir wrote:
>> On 07/08/2013 23:22, Eric Dumazet wrote:
>>> sk_mark_napi_id() in UDP are wrong IMHO.
>>>
>>> It should be guarded by the following test in  
>>> __udp_queue_rcv_skb()
>>>
>>> if (inet_sk(sk)->inet_daddr) {
>>>     sock_rps_save_rxhash(sk, skb);
>>>     sk_mark_napi_id(sk, skb);
>>> }
>>>
>>> (To occur only for connected UDP sockets, where we are 100% sure all
>>> packets will use this same rxhash/rx queue)
>>
>> This would also be safe if there is only one NIC and said NIC was
>> programmed to always place this socket's data on the same queue.
>>
>> I don't have a good suggestion on how to detect this.
> 
> Well, this stuff relies on flows being correctly steered.
> 
> TCP stack performs much better if we avoid reorders ;)

Let's limit the discussion to UDP for now.
If you are getting packets on multiple queues for a TCP socket,
it's hard to see how you can avoid caused reordering.

Maybe it would be enough to have a socket option that the user
can set to tell the stack "I know what I'm doing, please allow busy
polling on this UDP socket, even though it's not bound".
