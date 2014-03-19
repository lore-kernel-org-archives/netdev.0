From: Heiner Kallweit <heiner.kallweit@web.de>
Subject: Re: [PATCH net] ipv6: If a public address is deleted then also delete
 all temporary addresses still referring to it
Date: Wed, 19 Mar 2014 22:17:32 +0100
Message-ID: <532A096C.8030200@web.de>
References: <5328B0B0.7070305@web.de> <20140319202123.GH12291@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.12]:55462 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754828AbaCSVRk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Mar 2014 17:17:40 -0400
In-Reply-To: <20140319202123.GH12291@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 19.03.2014 21:21, schrieb Hannes Frederic Sowa:
> On Tue, Mar 18, 2014 at 09:46:40PM +0100, Heiner Kallweit wrote:
>> If a public address is deleted by an external trigger (e.g. via inet6_rtm_deladdr) then temporary
>> addresses still referring to it may remain. Happened here when the WiFi link broke and netifd
>> deleted the public address. Once the link was back and prefix_rcv created new public addresses
>> ipv6_create_tempaddr complained that the temporary address already existed.
> Which error was it specifically?
>
>> IMHO no temporary address should live longer than its parent, especially because ifpub of the
>> temporary address still points to the then deleted public address otherwise.
> Reference counting will take care of that.
>
>> Therefore delete all related temporary addresses before a public address is deleted in inet6_addr_del
>> which is called by inet6_rtm_del.
> I am a bit concerend with backward compatibility here.
>
>> Also ensure in ipv6_del_addr that no temporary address lives longer than its parent.
> I currently don't see a problem with that.
>
> Greetings,
>
>   Hannes
>
>

The specific error was "retry temporary address regeneration" caused by ipv6_add_addr returning EEXIST.

First question is whether it's correct that in case of link loss the public address is deleted but not the temporary addresses.
I don't think it's correct.
If it's not correct then the question is who's reponsibility it is to delete temporary addresses if the parent public address is deleted.
My solution was to do it in the kernel but this might not be the best / correct approach.
Would you prefer that userspace / netifd take care to also delete the temporary addresses?

Last but not least the question is whether the kernel should care in general about the situation that a public address is deleted and orphaned
temporary addresses are left behind.

Rgds, Heiner
