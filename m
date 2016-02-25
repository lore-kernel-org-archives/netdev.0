From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 3/4] net: sched: cls_u32 add bit to specify
 software only rules
Date: Thu, 25 Feb 2016 07:56:35 -0500
Message-ID: <56CEFA03.3080802@mojatatu.com>
References: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810>
 <20160223190321.5970.58924.stgit@john-Precision-Tower-5810>
 <56CDB0B0.4080609@mojatatu.com> <56CE7D37.9000701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>, jiri@resnulli.us,
	daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33255 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759756AbcBYM4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 07:56:38 -0500
Received: by mail-io0-f194.google.com with SMTP id g203so5530421iof.0
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 04:56:38 -0800 (PST)
In-Reply-To: <56CE7D37.9000701@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-24 11:04 PM, John Fastabend wrote:
> On 16-02-24 05:31 AM, Jamal Hadi Salim wrote:

> I think this is absolutely necessary not only for performance of
> reporting the rules back to software but if we don't do it generically
> the driver will have to do it anyways because doing the inverse
> transformation from hw implementation to u32 is really tricky and in
> fact with hnodes and knodes there are multiple cls_u32 "programs" that
> functionally are the same so we have no way to return what the user
> actually programmed without it. Further eBPF (the next classifier I'm
> working on) is even worse in this regard.

Ok, I guess there are multiple use cases for it ;->
Yes, with ebpf it will be worse because data and instructions are
inter- mingled (and our interest is in data only). Note:
Over the years this has been a big struggle for human
friendliness. I thought we didnt care about humans (as in automation)
but you are saying this will affect machines too ;-> We cant allow
that ;->

Note: You could decode u32 descriptions but it is an involved effort.
Example, see this feature in tc:
---
jhs@jhs1 tc -pretty filter ls dev $ETH parent ffff: protocol ip
filter pref 11 u32
filter pref 11 u32 fh 800: ht divisor 1
filter pref 11 u32 fh 800::800 order 2048 key ht 800 bkt 0 flowid 1:1
   match IP src 10.0.0.130/32
	action order 1: gact action drop
	 random type none pass val 0
	 index 1 ref 1 bind 1
----
See that "match" field reading in anglais? It requires more and more
additions of pretty printers that translate back.

What about adding some tag to allow for easy "babel translation"?

> You can see my solution to
> this "load in hardware" filter list in patch 4/4. See Jiri's comment
> also on that and see if you agree.

Ok, will do.

cheers,
jamal
