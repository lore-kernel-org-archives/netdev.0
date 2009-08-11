From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 13954] New: Oops in rtnetlink code when creating
 can device
Date: Tue, 11 Aug 2009 11:33:35 +0200
Message-ID: <4A813AEF.7000002@trash.net>
References: <bug-13954-10286@http.bugzilla.kernel.org/> <20090810215436.0bf47297.akpm@linux-foundation.org> <4A812354.8090704@volkswagen.de> <4A812A3C.10207@trash.net> <4A813963.10407@volkswagen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Wolfgang Grandegger <wg@grandegger.com>, dbaryshkov@gmail.com,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	"Thuermann, Urs, Dr. (K-EFFI/I)" <urs.thuermann@volkswagen.de>,
	Lothar Wassmann <LW@KARO-electronics.de>,
	netdev@vger.kernel.org
To: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64683 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752944AbZHKMgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 08:36:32 -0400
In-Reply-To: <4A813963.10407@volkswagen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Hartkopp wrote:
>>> For real hardware CAN devices the netlink interface is only used for the
>>> configuration of already existing interfaces.
>>> From a quick view on the rtnl_newlink() function in net/core/rtnetlink.c
>>> i was not able to find any method to disallow the creation of
>>> interfaces, will say: How can a netlink user provide the information,
>>> that he's not able to create new devices via netlink???
>>>
>>> @Patrick: Do you have an idea for this? Is it a new use-case for netlink
>>> that needs to be implemented?
>>>     
>>
>> You could add a ->newlink() function that unconditionally returns
>> an error.
>>
>>   
> 
> Yes, that fixed it.
> 
> I created a can_newlink() function just returning -EINVAL ...
> 
> I'll cook a patch and send it on netdev (when it gets online again).

I'd suggest to use EOPNOTSUPP for consistency.
