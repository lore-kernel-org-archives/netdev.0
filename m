From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 0/5] net_sched: Add support for IFE action
Date: Wed, 24 Feb 2016 18:48:21 +0100
Message-ID: <56CDECE5.5040604@iogearbox.net>
References: <1456147304-13355-1-git-send-email-jhs@emojatatu.com> <56CB3B90.8030206@iogearbox.net> <56CC4BEA.70108@mojatatu.com> <56CC5CB6.1030807@iogearbox.net> <56CC6C75.1000903@mojatatu.com> <56CC7C20.3090302@iogearbox.net> <56CDA6E8.7010604@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	alexei.starovoitov@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33794 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754671AbcBXRs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 12:48:28 -0500
In-Reply-To: <56CDA6E8.7010604@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/24/2016 01:49 PM, Jamal Hadi Salim wrote:
> On 16-02-23 10:34 AM, Daniel Borkmann wrote:
>> On 02/23/2016 03:28 PM, Jamal Hadi Salim wrote:
> [..]
>
>>> These are basic metadata. The question to ask is what could one use
>>> skb->hash for. Today it is used to select a cpu to balance to.
>>
>> Right, but that happens before you decode that information from your TLV
>> on ingress qdisc. And any subsequent skb_get_hash() to read out skb->hash
>> will effectively overwrite what you set there and call into flow dissector.
>
> Drivers do set the hash. My use case is slightly different.
> I have a NIC which has an embedded cavium processor. This thing
> strips off the TLV and uses the hash to select the host MSI.
> Only thing we dont use at the moment is queue_mapping.

Ok, but the example says ingress qdisc. ;) I presume the driver for the
NIC and the offloading parts are non-public? :/ So, without them, placing
this on ingress qdisc doesn't seem much useful wrt the skb hash example,
and most people only have the software part (for ingress I mean) available.
