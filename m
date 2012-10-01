From: Chris Clayton <chris2553@googlemail.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Mon, 01 Oct 2012 16:13:04 +0100
Message-ID: <5069B300.9080308@googlemail.com>
References: <5057455A.7050108@googlemail.com>  <50588371.40103@googlemail.com>  <505885DC.1060006@googlemail.com>  <1347979239.26523.267.camel@edumazet-glaptop>  <5059E40C.4070607@googlemail.com> <505D5A18.2080507@googlemail.com>  <50643DA1.7070306@googlemail.com>  <1348748042.5093.1168.camel@edumazet-glaptop>  <50649567.2010704@googlemail.com>  <1348779826.5093.1750.camel@edumazet-glaptop>  <1348780624.5093.1767.camel@edumazet-glaptop>  <50656C4A.8090302@googlemail.com>  <1348831592.5093.2251.camel@edumazet-glaptop>  <5068648C.7050005@googlemail.com>  <1349034330.12401.210.camel@edumazet-glaptop>  <506955F3.8050304@googlemail.com> <1349082950.12401.669.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gpiez@web.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:41297 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193Ab2JAPNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 11:13:05 -0400
Received: by bkcjk13 with SMTP id jk13so5022280bkc.19
        for <netdev@vger.kernel.org>; Mon, 01 Oct 2012 08:13:03 -0700 (PDT)
In-Reply-To: <1349082950.12401.669.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/01/12 10:15, Eric Dumazet wrote:
> On Mon, 2012-10-01 at 09:36 +0100, Chris Clayton wrote:
>>
>
>>       0 ICMP messages received
>>       0 input ICMP message failed.
>>       ICMP input histogram:
>>       0 ICMP messages sent
>>       0 ICMP messages failed
>>       ICMP output histogram:
>
>>
>> After:
>>
>> $ netstat -s
>> Icmp:
>>       4 ICMP messages received
>>       4 input ICMP message failed.
>>       ICMP input histogram:
>>           echo replies: 4
>
> So icmp replies come back and are delivered to host instead of being
> forwarded.
>
> I wonder if MASQUERADE broke...
>
> Could you send
>
> iptables -t -nat -nvL

$ iptables -t -nat -nvL
iptables v1.4.15: can't initialize iptables table `-nat': Table does not 
exist (do you need to insmod?)
Perhaps iptables or your kernel needs to be upgraded.

> conntrack -L   # while ping is running from guest

$ conntrack -L
conntrack v1.2.2 (conntrack-tools): Operation failed: invalid parameters

Forgive me for asking, but why is the problem not down to the change 
that I identified by bisecting? The title of the patch is "ipv4: Cache 
local output routes" and, although I'm a million miles from being an 
expert here, to me it does make it look a good candidate. 
http://marc.info/?l=linux-netdev&m=134797809611847&w=2

>
>
>
