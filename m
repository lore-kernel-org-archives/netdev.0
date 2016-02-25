From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH 3/4] net: sched: cls_u32 add bit to specify
 software only rules
Date: Thu, 25 Feb 2016 18:05:45 -0500
Message-ID: <56CF88C9.8050005@mojatatu.com>
References: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810>
 <20160223190321.5970.58924.stgit@john-Precision-Tower-5810>
 <56CDB0B0.4080609@mojatatu.com> <56CE7D37.9000701@gmail.com>
 <56CEFA03.3080802@mojatatu.com> <56CF787B.2070505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>, jiri@resnulli.us,
	daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f196.google.com ([209.85.213.196]:32898 "EHLO
	mail-ig0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751268AbcBYXFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 18:05:50 -0500
Received: by mail-ig0-f196.google.com with SMTP id hb3so2323676igb.0
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 15:05:49 -0800 (PST)
In-Reply-To: <56CF787B.2070505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-25 04:56 PM, John Fastabend wrote:
> On 16-02-25 04:56 AM, Jamal Hadi Salim wrote:

>
> decoding that is not a problem. The ixgbe driver code already applied
> can decode that without much trouble. The thing I want to avoid is
> requiring my driver to do the inverse translation because although it
> is possible its entirely unnecessary.
>
> To do the above example without a software cache for example
> means I read out row 2048 of a hardware table then you get a bunch of
> bits. From those bits I consult what fields are being loaded into
> the table in the packet processing pipeline. I learn its the src_ip
> fields then I have the value/mask and can unwind it. Finally if I
> collapsed some hash tables onto this hardware table I have to do the
> inverse of my collapsing scheme. The ixgbe one is sort of simple just
> because I only have one table in hardware but with multiple tables
> its a bit more difficult. Finally I've unwound the thing and can
> print something back out of 'tc' but it seems easier to just cache
> the hardware rules somewhere. Maybe other driver/hardware will have
> a different opinion though depending on how much your firmware can
> store and how ambitious you are. Personally I don't see any need
> for the above code.
>

I think if you can cache the rules and have a way to easily map to
the hardware then this would work fine.

cheers,
jamal
