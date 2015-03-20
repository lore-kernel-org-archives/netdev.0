From: Cong Wang <cwang@twopensource.com>
Subject: Re: cgroup matches in INPUT chain
Date: Fri, 20 Mar 2015 13:55:11 -0700
Message-ID: <CAHA+R7MrL4kW5W=1LZFzXzkb1zWUxHRXHwjjnksScWF1ZMHswQ@mail.gmail.com>
References: <550B1852.2020209@zonque.org>
	<20150319185807.GA3845@breakpoint.cc>
	<550C2753.9020608@zonque.org>
	<20150320161111.GA11498@breakpoint.cc>
	<550C4901.4070001@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexey Perevalov <a.perevalov@samsung.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>
To: Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:33424 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751120AbbCTUzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 16:55:12 -0400
Received: by ignm3 with SMTP id m3so3055592ign.0
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 13:55:11 -0700 (PDT)
In-Reply-To: <550C4901.4070001@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 9:21 AM, Daniel Mack <daniel@zonque.org> wrote:
> On 03/20/2015 05:11 PM, Florian Westphal wrote:
>> Daniel Mack <daniel@zonque.org> wrote:
>>> In my simple test setup, when skbs are dequeued by process_backlog(),
>>> they have skb->_skb_refdst set, and hence ip_rcv_finish() does not call
>>> into early_demux() prior to iterating the INPUT chain:
>>
>> Yes, because we already have a route set.
>>
>> Are we talking about loopback?
>
> I'm testing this on the lookback device, but I've seen similar behavior
> on external interfaces too. However, I fail to see a pattern in that.
>

Loopback is special because the skb->dst is kept across TX and RX.

How possible is your external interface sets dst for the packets?
Are you using a tunnel device or you have some other setup you didn't mention?
