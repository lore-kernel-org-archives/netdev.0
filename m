From: Luuk Paulussen <Luuk.Paulussen@alliedtelesis.co.nz>
Subject: Re: Increasing skb->mark size
Date: Tue, 1 Dec 2015 00:12:24 +0000
Message-ID: <565CE5E8.9010002@alliedtelesis.co.nz>
References: <CAKD1Yr3URKzAooiNH7i4kHVR0-TQjEAkQEdqjarAm6uxH7u-Mw@mail.gmail.com>
 <20151129.205854.160622377475841200.davem@davemloft.net>
 <565BCC42.7020701@alliedtelesis.co.nz>
 <20151129.234955.2156041834628417171.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "lorenzo@google.com" <lorenzo@google.com>,
	Matt Bennett <Matt.Bennett@alliedtelesis.co.nz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:36332 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754496AbbLAAMf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 19:12:35 -0500
In-Reply-To: <20151129.234955.2156041834628417171.davem@davemloft.net>
Content-Language: en-US
Content-ID: <98241292EFEA87468DF78C0D4DED018A@atlnz.lc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/30/2015 05:49 PM, David Miller wrote:
> From: Luuk Paulussen <Luuk.Paulussen@alliedtelesis.co.nz>
> Date: Mon, 30 Nov 2015 04:10:43 +0000
>
>> On 11/30/2015 02:58 PM, David Miller wrote:
>>> If you guys, really anyone, can find a way to remove some other 32-bit
>>> item from sk_buff, you can expand skb->mark to 64-bits. But otherwise,
>>> I'm going to be strongly against it. sk_buff is already enormous and
>>> larger than it should be. So I'm going to resist any change that makes
>>> it even larger. Thanks.
>> Would the level of objection be the same if this was done as an
>> "extended mark" field under a configurable off-by-default option?
> Every distribtion will turn the option on.
>
> Config options hiding "cost" is never an argument to bloat
> a critical core datstructure up, sorry.
>
Fair enough, although if most distributions would turn it on, it does 
suggest that it is interesting...

I have been looking at the tc_index field in the skb, and I think that 
this might fit our current purposes with some modifications.
The extra bits we are currently looking for are actually for traffic 
control.

We would need a marking target for tc_index in nf/ip tables and a way to 
save/restore it into the connmark.
This would become an additional method of setting tc_index alongside 
dsmark, and the existing tcindex tc classifier can then be used to 
classify the packets.

The only data structure change needed for this would be to add a u16 
tc_index to the nf_conn structure, as we would still
want to reduce the number of rules processed for each individual packet 
by restoring the mark from the connection for all
but the first packet in each flow.

Would this be an acceptable alternative, or is the nf_conn structure 
size restricted in the same way as the sk_buff?