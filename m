From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v2] ipv6: enable anycast addresses as source
 addresses in ICMPv6 error messages
Date: Fri, 07 Feb 2014 10:33:29 +0100
Message-ID: <52F4A869.6090401@6wind.com>
References: <1390147236-3660-1-git-send-email-fx.lebail@yahoo.com> <52F357C3.9060406@6wind.com> <1391690329.62545.YahooMailNeo@web125506.mail.ne1.yahoo.com> <52F395BB.2030209@6wind.com> <1391697041.6325.YahooMailNeo@web125505.mail.ne1.yahoo.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Stevens <dlstevens@us.ibm.com>,
	Bill Fink <billfink@mindspring.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: =?ISO-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:33772 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771AbaBGJdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 04:33:33 -0500
Received: by mail-wi0-f180.google.com with SMTP id hm4so637389wib.1
        for <netdev@vger.kernel.org>; Fri, 07 Feb 2014 01:33:31 -0800 (PST)
In-Reply-To: <1391697041.6325.YahooMailNeo@web125505.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06/02/2014 15:30, Fran=E7ois-Xavier Le Bail a =E9crit :
>> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>
>> To: Fran=E7ois-Xavier Le Bail <fx.lebail@yahoo.com>; "netdev@vger.ke=
rnel.org" <netdev@vger.kernel.org>
>> Cc: David Stevens <dlstevens@us.ibm.com>; Bill Fink <billfink@mindsp=
ring.com>; Hannes Frederic Sowa <hannes@stressinduktion.org>; David S. =
Miller <davem@davemloft.net>; Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>; =
James Morris <jmorris@namei.org>; Hideaki Yoshifuji <yoshfuji@linux-ipv=
6.org>; Patrick McHardy <kaber@trash.net>
>> Sent: Thursday, February 6, 2014 3:01 PM
>> Subject: Re: [PATCH net-next v2] ipv6: enable anycast addresses as s=
ource addresses in ICMPv6 error messages
>>
>> Le 06/02/2014 13:38, Fran=E7ois-Xavier Le Bail a =E9crit :
>>>>   From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>>
>>>
>>>>   Subject: Re: [PATCH net-next v2] ipv6: enable anycast addresses =
as
>> source addresses in ICMPv6 error messages
>>>>
>>>>   Le 19/01/2014 17:00, Francois-Xavier Le Bail a =E9crit :
>>>>
>>>>>     - Uses ipv6_anycast_destination() in icmp6_send().
>>>>>
>>>>>     Suggested-by: Bill Fink <billfink@mindspring.com>
>>>>>     Signed-off-by: Francois-Xavier Le Bail
>> <fx.lebail@yahoo.com>
>>>>   This patch causes an Oops on my target.
>>>
>>>   What is your target ?
>> x86 32bits
>>
>>>
>>>>   Here is the step to reproduce it:
>>>>   modprobe sit
>>>>   ip link add sit1 type sit remote 10.16.0.121 local 10.16.0.249
>>>>   ip l s sit1 up
>>>>   ip -6 a a dev sit1 2001:1234::123 remote 2001:1234::121
>>>>   ping6 2001:1234::121
>>>
>>>   I cannot reproduce this in my target (updated net-next x86_64) an=
d
>>>   iproute2 from git.
>> I use linus tree (3.14-rc1+).
>>
>>>   Can you send me your config file ?
>> See attachment.
>>
>>
>>>
>>>>   The problem is that ipv6_anycast_destination() uses unconditiona=
lly
>>>>   skb_dst(skb), which is NULL in this case.
>>>>
>>>>   Not sure what is the best way to fix this, any suggestions?
>>>
>>>   I will try to reproduce first and see.
>> Note that the peer was not set up, hence the ping didn't work.
>> ipip6_err() calls ipip6_err_gen_icmpv6_unreach() which will drop the=
 dst
>> before calling icmpv6_send().
>>
>>
>> Here is the backtrace:
>> [  387.786155] BUG: unable to handle kernel NULL pointer dereference=
 at 00000096
>> [  387.787291] IP: [<c12f1568>] icmp6_send+0x79/0x596
>
> [...]
>
>> [  387.790055]  [<f85ce03b>] ? tunnel64_err+0x16/0x25 [tunnel4]
>
> Thanks for these informations.
>
> Can you test an alternative replacing:
>
> test on: ipv6_anycast_destination(skb)
> by
> test on: ipv6_chk_acast_addr_src(net, skb->dev, &hdr->daddr)
It's ok with this function. Do you submit the corresponding patch?
