From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH 2/2 net-next] net: move qdisc ingress filtering code where
 it belongs
Date: Sun, 10 May 2015 11:47:01 -0700
Message-ID: <554FA7A5.5020400@plumgrid.com>
References: <1431277170-4618-1-git-send-email-pablo@netfilter.org> <1431277170-4618-3-git-send-email-pablo@netfilter.org> <554F9946.9040707@plumgrid.com> <20150510175934.GA3799@salvia> <554F9DE8.3000507@plumgrid.com> <20150510182414.GA4198@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
	daniel@iogearbox.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:35616 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbbEJSrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 14:47:04 -0400
Received: by ieczm2 with SMTP id zm2so94355842iec.2
        for <netdev@vger.kernel.org>; Sun, 10 May 2015 11:47:04 -0700 (PDT)
In-Reply-To: <20150510182414.GA4198@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/10/15 11:24 AM, Pablo Neira Ayuso wrote:
> On Sun, May 10, 2015 at 11:05:28AM -0700, Alexei Starovoitov wrote:
>> On 5/10/15 10:59 AM, Pablo Neira Ayuso wrote:
>>> No, Daniel is *not* benchmarking the netif_received_core() with no
>>> filtering at all.
>>
>> sorry, not true. We did benchmark all combinations. Daniel posted
>> his, I'll send numbers from my box as well.
>
> Daniel said:
>
> "The extra indirection layers however, are not necessary for calling
> into ingress qdisc. pktgen calling locally into netif_receive_skb()
> with a dummy u32, single CPU result on a Supermicro X10SLM-F, Xeon
> E3-1240: before ~21,1 Mpps, after patch ~22,9 Mpps."
>
> That explicitly refers to u32, hence qdisc ingress, so he did *not*
> post any number of the use case I'm indicating.

I think I'm starting to understand your concern.
You've read the patch in a way that it slows down netif_receive
_without_ ingress qdisc? Of course, that's not the case.

Here are the number from my box:
before:
no ingress - 37.6
ingress on other dev - 36.5
ingress on this dev - 28.8
ingress on this dev + u32 - 24.1

after Daniel's two patches:
no ingress - 37.6
ingress on other dev - 36.5
ingress on this dev - 36.5
ingress on this dev + u32 - 25.2

so when ingress qdisc is not used, the difference is zero.
When ingress qdisc is added to another device - difference is zero.
The last two numbers that we wanted to accelerate and we did.
