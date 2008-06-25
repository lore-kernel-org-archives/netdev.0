From: "Fey Marcus" <Fey@iabg.de>
Subject: RE: (usagi-users 04056) Re: ping6 is sent out from wrong interface
Date: Wed, 25 Jun 2008 13:26:06 +0200
Message-ID: <69A5E767EC979846826F566C7932A3F207233D99@exchange03.iabg.de>
References: <4861ED72.6080100@miraclelinux.com> <69A5E767EC979846826F566C7932A3F207233B5F@exchange03.iabg.de> <48621B7E.5090600@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-2022-JP"
Content-Transfer-Encoding: 8BIT
Cc: <usagi-users@ml.linux-ipv6.org>,
	=?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>, <netdev@vger.kernel.org>,
	<usagi-users@linux-ipv6.org>
To: "Naohiro Ooiwa" <nooiwa@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.iabg.de ([62.245.167.132]:33231 "EHLO mail2.iabg.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752012AbYFYL0J convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2008 07:26:09 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <48621B7E.5090600@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Naohiro,

>
>Hi Marcus
>
>Thank you for your quick reply.
>
>> It's due to routing.
>
>For the reason of selecting 'eth0', I agree.
>But, I think the device is specified before looking up the 
>routing table in this case.

Well, ping's man page reads: 
---
       -I interface address
              Set source address to specified interface  address.  Argument
              may  be  numeric  IP  address or name of device. When pinging
              IPv6 link-local address this option is required.
---

So you only set the address, not the interface to be used for sending.

>
>> ...with eth0 being preferred over eth1 for multicast packets.
>> You could add a dedicated route for ff02::/16 to make the 
>kernel output the packet via eth1.
>
>This works when using only "eth1" for multicasts.
>When multiple I/Fs are connected to separate networks, this 
>scheme requires changing the route every time a user need to 
>send ping to different network.
>

Ok, my proposition was a bit too general. It would probably be better to set up routes for the exact addresses. So in your case to ff02::1. 

Of course, if you wish to send the same packet via several interfaces within a short time, this would still result in adding and deleting the routes over and over again.

>I think kernel can solve this problem better.
>

I don't think this would be intended....


Bye,

Marcus
-----------------------------------------
IABG mbH
Sitz der Gesellschaft: Ottobrunn, Registergericht: Amtsgericht Muenchen, HRB 5499
Geschaeftsfuehrung: Prof. Dr.-Ing. Rudolf F. Schwarz
Vorsitzender des Aufsichtsrats: General a. D. Wolfgang Altenburg

