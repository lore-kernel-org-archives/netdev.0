From: Zacco <zacco@fw.hu>
Subject: Re: many sockets, slow sendto
Date: Sun, 22 Apr 2007 14:34:18 +0200
Message-ID: <462B564A.2020109@fw.hu>
References: <E1HObHK-0000WB-00@osiris.swi.hu>	<20070306182039.GJ25760@galon.ev-en.org>	<45FF185B.4070007@fw.hu>	<20070319.161611.70218081.davem@davemloft.net>	<4600592E.80605@fw.hu>	<460064C6.5030302@cosmosbay.com>	<4601ADD8.8040500@cosmosbay.com>	<460C126F.7050303@fw.hu> <20070330151021.d067d837.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, baruch@ev-en.org,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta02.mail.t-online.hu ([195.228.240.51]:59932 "EHLO
	mta02.mail.t-online.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030576AbXDVMhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Apr 2007 08:37:04 -0400
In-Reply-To: <20070330151021.d067d837.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Eric and all,

Thanks a lot. However, some chunks still resisted to apply, the manual
patching worked. I tested and the results are more than satisfactory.
Not just the reception part became faster, but also the bind calls. The
gain is especially significant when increasing the hash table size. I
applied it in an older kernel with similar success. Basically, my
problem is solved.

I have just one question: Why do you check the address in
__udp_lib_port_inuse? I think it is enough to check the port, as the
name of the function suggests, but I may be wrong. I removed it and the
patch still works fine, but for me this is not a proof, as I may use it
in some special case.

As for your confusion: You're right. My idea to include the both sockets
in the hash function was really unnecessary, even in my example. Thx for
revealing that!

I applied another modification in the patch: I called the hash function
from __udp_lib_port_inuse, instead passing the hash value. This way, I
could reduce the number modifications, so the patch is easier to apply
manually to whatever kernel version.

Thx: Zacco


Eric Dumazet wrote:
> On Thu, 29 Mar 2007 21:24:31 +0200
> Zacco <zacco@fw.hu> wrote:
>
>   
>> Hi,
>>
>> Thanks for the patch. I almost dare not confess that I don't know which 
>> version to apply to. I tried 3 different ones (2.6.19-r5-gentoo, 
>> 2.6.20.1 and 2.6.21-rc4), but in the best case at least two hunks 
>> failed. Nevertheless, I applied the patches manually. In each case, UDP 
>> stopped working. I guess, you checked the patch and worked. I don't 
>> think I made a mistake in the manual copy, and it seems unlikely that 
>> your patch interfered with other parallel changes in the kernel - but, 
>> I'm just guessing ...
>> I think, I'd better send you the spec and code, as you suggested that 
>> first we have a common understanding of the issue. I must have failed in 
>> passing the point. I'm removing irrelevant stuff, and I send it to you 
>> as soon as I can (sorry for my long delays).
>>
>> thx a lot,
>> Zacco
>>     
>
> Hum, please find a (working) patch against linux-2.6.21-rc5
>
> (first patch was against net-2.6.22 git tree and had one bug)
>
> ...
