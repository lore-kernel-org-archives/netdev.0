From: Satoru Moriya <satoru.moriya@hds.com>
Subject: RE: [RFC][PATCH] add tracepoint to __sk_mem_schedule
Date: Wed, 15 Jun 2011 16:15:27 -0400
Message-ID: <65795E11DBF1E645A09CEC7EAEE94B9C3FBC070A@USINDEVS02.corp.hds.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9C3FBC0707@USINDEVS02.corp.hds.com>
 <20110615110723.GA23380@hmsreliant.think-freely.org>
 <65795E11DBF1E645A09CEC7EAEE94B9C3FBC0709@USINDEVS02.corp.hds.com>,<20110615200405.GB23380@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"dle-develop@lists.sourceforge.net"
	<dle-develop@lists.sourceforge.net>,
	Seiji Aguchi <seiji.aguchi@hds.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usindmx01.hds.com ([207.126.252.12]:34707 "EHLO
	usindmx01.hds.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751573Ab1FOURO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2011 16:17:14 -0400
In-Reply-To: <20110615200405.GB23380@hmsreliant.think-freely.org>
Content-Language: ja-JP
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/15/2011 04:04 PM, Neil Horman wrote:
> On Wed, Jun 15, 2011 at 03:18:09PM -0400, Satoru Moriya wrote:
>
>> Right. We can catch packet drop events via dropwatch/kfree_skb tracepoint.
>> OTOH, what I'd like to know is why kernel dropped packets. Basically,
>> we're able to know the reason because kfree_skb tracepoint records its
>> return address. But in this case it is difficult to know a detailed reason
>> because there are some possibilities. I'll try to explain UDP case.
> Ok, but you're patch only gets us incrmentally closer to that goal.  You can
> tell if theres too much memory pressue to accept another packet on a socket, but
> it doesn't tell you if for instance if sk_filter indicated an error, or
> something else failed.  In short it sounds to me like you're trying to debug a
> specific problem, rather than add something generally useful.

You're right.

>> As you said, we're able to catch the packet drop in __udp_queue_rcv_skb
>> and it means ip_queue_rcv_skb/sock_queue_rcv_skb returned negative value.
>> In sock_queue_rcv_skb there are 3 possibilities where it returns nagative
>> val but we can't separate them from the kfree_skb tracepoint. Moreover
> This is true, but you're patch doesn't do that either (not that either feature
> holds that as a specific goal).

Right.

> 
>> sock_queue_rcv_skb calls __sk_mem_schedule and there are several
>> if-statement to decide whether kernel should drop a packet in it. I'd like
>> to know the condition when it returned error because some of them are
>> related to sysctl knob e.g. /proc/sys/net/ipv4/udp_mem, udp_rmem_min,
>> udp_wmem_min for UDP case and we can tune kernel behavior easily.
>> Also they are needed to show root cause of packet drop to our customers.
>>
>> Does it make sense?
>>
> Yes, it makes sense, but I think the patch could be made generally more useful.

OK. I'll update my patch to make it more useful.

Thanks,
Satoru