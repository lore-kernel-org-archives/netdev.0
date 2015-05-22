From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH net-next v2 0/7] netns: ease netlink use with a lot of
 netns
Date: Fri, 22 May 2015 23:12:40 +0200
Message-ID: <555F9BC8.1040509@ahsoftware.de>
References: <1430906288-5108-1-git-send-email-nicolas.dichtel@6wind.com>	<1430989373-4515-1-git-send-email-nicolas.dichtel@6wind.com>	<874mnn9t12.fsf@x220.int.ebiederm.org>	<555F969B.3090706@ahsoftware.de> <CAHA+R7NCjKn86R+OLX+4bkB0kv3WcXGB5NPui+v_X=CKqQtPLA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>,
	David Miller <davem@davemloft.net>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1446028.stratoserver.net ([85.214.92.142]:57173 "EHLO
	mail.ahsoftware.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756771AbbEVVMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 17:12:47 -0400
Received: from wandq.ahsoftware (p4FC3696B.dip0.t-ipconnect.de [79.195.105.107])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.ahsoftware.de (Postfix) with ESMTPSA id C97B92C9C1BF
	for <netdev@vger.kernel.org>; Fri, 22 May 2015 23:12:45 +0200 (CEST)
In-Reply-To: <CAHA+R7NCjKn86R+OLX+4bkB0kv3WcXGB5NPui+v_X=CKqQtPLA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 22.05.2015 um 23:04 schrieb Cong Wang:
> On Fri, May 22, 2015 at 1:50 PM, Alexander Holler <holler@ahsoftware.de> wrote:
>> Am 08.05.2015 um 14:02 schrieb Eric W. Biederman:
>>>
>>>
>>> So I am dense.  I have read through the patches and I don't see where
>>> you tag packets from other network namespaces with a network namespace
>>> id.
>>
>>
>> Me too,
>>
>> I've recently written a little tool called snetmanmon (source is
>> available at github) to monitor and handle network related events
>> by using rtnetlink.
>>
>> Having seen this patch series (thanks!), I've played with it.
>>
>> I've applied the patch series to v4.1-rc4.
>>
>> Maybe I'm using or holding it wrong, but I've some comments.
>>
>> First I think if NETLINK_LISTEN_ALL_NSID is enabled, a dump
>> of the interfaces through RTM_GETLINK together with NLM_F_DUMP and
>> NLM_F_REQUEST should return all interfaces of all reachable namespaces.
>>
>> Next, if NETLINK_LISTEN_ALL_NSID is enabled, I receive RTM_NEWLINK
>> but without any indication of the namespace. E.g. if I do
>>          ip netns add netns1
>>          ip netns exec netns1 brctl addbr br0
>> the RTM_NEWLINK for br0 (received in the root ns, not netns1) doesn't
>> have the attribute IFLA_LINK_NETNSID.
>
>
> Bridge doesn't have an underlying link, so no LINK_NETNSID. LINK_NETNSID
> is only added when its underlying link is in a different netns.

I'm using "link" similiar as interface. Maybe I've no idea what the 
attribute LINK:NETSID really means, but I've understood it as the one 
attribute which indicates the namespace an interface (or link), br0 in 
my example, lives in.

Regards,

Alexander Holler
