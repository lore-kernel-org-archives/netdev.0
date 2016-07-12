From: Alan Davey <Alan.Davey@metaswitch.com>
Subject: RE: [PATCH] net: Fragment large datagrams even when IP_HDRINCL is
 set.
Date: Tue, 12 Jul 2016 12:34:07 +0000
Message-ID: <SN1PR0201MB1807CF3E6A28E344EE2E41F0F9300@SN1PR0201MB1807.namprd02.prod.outlook.com>
References: <20160608.102558.903056863834035706.davem@davemloft.net>
	<BN3PR0201MB10599C7780CBC6EB4BC2894DF9550@BN3PR0201MB1059.namprd02.prod.outlook.com>
	<alpine.LFD.2.20.1607081340430.26593@stoner.jakma.org>
 <20160708.184129.1545084362199727100.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>
To: David Miller <davem@davemloft.net>,
	"paul@jakma.org" <paul@jakma.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0130.outbound.protection.outlook.com ([104.47.42.130]:59232
	"EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750968AbcGLNH7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 09:07:59 -0400
In-Reply-To: <20160708.184129.1545084362199727100.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> On Wed, 15 Jun 2016, Alan Davey wrote:
>> 
>>> The only case that would break is that where an application relies on 
>>> the existing (documented as a bug) feature of getting an EMSGSIZE 
>>> return code in the case of an over-sized packet.  Applications that 
>>> perform their own fragmentation would be unaffected.
>> 
>> If this doesn't break existing applications that are doing 
>> fragmentation in userspace on raw sockets (e.g. Quagga ospfd), that's 
>> better.
>> 
>> As per previous email, I'd love to be able to get rid of that code and 
>> have the kernel do it for me. However, I also don't want to have to do 
>> anything other non-trivial to that code either. :)
>> 
>> The issue for us is, how would we know on any given host whether the 
>> kernel will do the fragmentation or whether ospfd has to do it? We 
>> need to be able to probe for that capability, surely?
>
>The fact is, regardless of whether you could probe for the capability or not, you have to keep the fragmentation code around forever.
>
>And that is yet another reason I do not want to add this change at all.
>
>It doesn't make any existing server any simpler, in fact it makes them all more complicated because not only do they keep the fragmentation code, they also >get new logic to test for the feature that would allow them to avoid using it.
>
>Sorry, there is no way I am adding this, it's a net lose.

David,

I accept you don't want to take this patch.  However, I don't yet understand why, so I have a few more questions (which will hopefully help me produce patches that are likely to be accepted in future).

Adding the patch means that some existing applications will continue to contain their own fragmentation code, which becomes unnecessary.  This is OK; those applications will continue to fragment packets, and will continue to work with an updated kernel.  Do you agree?

Not adding the patch means that 
-  all future applications have to continue to implement their own fragmentation code, duplicating that which already exists in the kernel
-  hardware vendors may choose to apply the patch themselves (they do not want to implement function that already exists), but would surely prefer to have it in the standard kernel.

So I still don't understand what part of taking the patch would have a negative result on existing applications, it should be neutral to them.  Could you help me out here and explain?

Regards
Alan
