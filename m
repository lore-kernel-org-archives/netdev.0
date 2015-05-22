From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH net-next v2 0/7] netns: ease netlink use with a lot of
 netns
Date: Fri, 22 May 2015 23:46:47 +0200
Message-ID: <555FA3C7.7060301@ahsoftware.de>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>	<1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com>	<874mnn9t12.fsf@x220.int.ebiederm.org>	<555F969B.3090706@ahsoftware.de>	<CAHA+R7NCjKn86R+OLX+4bkB0kv3WcXGB5NPui+v_X=CKqQtPLA@mail.gmail.com>	<555F9BC8.1040509@ahsoftware.de> <CAHA+R7O7sVkA7Ku13gKbwa9HZ0gJZm5kw09Oeiy4u1ZMiv=ijA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1446028.stratoserver.net ([85.214.92.142]:59530 "EHLO
	mail.ahsoftware.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161098AbbEVVq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 17:46:56 -0400
Received: from wandq.ahsoftware (p4FC3696B.dip0.t-ipconnect.de [79.195.105.107])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.ahsoftware.de (Postfix) with ESMTPSA id E762D2C9C1D5
	for <netdev@vger.kernel.org>; Fri, 22 May 2015 23:46:53 +0200 (CEST)
In-Reply-To: <CAHA+R7O7sVkA7Ku13gKbwa9HZ0gJZm5kw09Oeiy4u1ZMiv=ijA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 22.05.2015 um 23:29 schrieb Cong Wang:
> On Fri, May 22, 2015 at 2:12 PM, Alexander Holler <holler@ahsoftware.de> wrote:
>>>
>>> Bridge doesn't have an underlying link, so no LINK_NETNSID. LINK_NETNSID
>>> is only added when its underlying link is in a different netns.
>>
>>
>> I'm using "link" similiar as interface. Maybe I've no idea what the
>> attribute LINK:NETSID really means, but I've understood it as the one
>> attribute which indicates the namespace an interface (or link), br0 in my
>> example, lives in.
>>
>
> It is for an underlying link for example: a veth pair is a link for each other,
> a tunnel device has a link to transmit packets.
>
> Bridge and bonding are master devices where "slaves" (or ports for bridge)
> can join.
>
> netns doesn't have a name or id by nature, we assign it a name by binding
> mount some /proc file, these LINK_NETNSID's are not absolutely unique either,
> just relatively.
>

Hmm. so making an inventory of all existing interfaces in all namespaces 
is either not really possible or ugly. If these IDs are not unique, what 
will I get when dumping the NETSID's? Sounds like I better forget that 
approach of using these IDs which means I would have to travel through 
the mounts and have to use GETLINK (with dump) from inside these 
namespaces, while having to identify the namespaces by their mount. That 
leads me to the problem how to find these mounts and ...

Not sure if I want to do that. It looked so easy to support namespaces 
but know it looks rather complicated.

Anyway, thanks a lot for the quick and fast responses and explanations.

Regards,

Alexander Holler
