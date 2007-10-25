From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [NETNS] Oops in register_pernet_operations() with CONFIG_NET_NS=n
Date: Thu, 25 Oct 2007 17:10:38 +0200
Message-ID: <4720B1EE.8050507@bull.net>
References: <47209317.8000802@bull.net> <4720A181.3060003@sw.ru>	<4720AD20.5030902@bull.net> <m17ilb6xs9.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Denis V. Lunev" <den@sw.ru>, Pavel Emelianov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Cedric Le Goater <clg@fr.ibm.com>,
	Linux Containers <containers@lists.osdl.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:55528 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758476AbXJYPLG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 11:11:06 -0400
In-Reply-To: <m17ilb6xs9.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> Benjamin Thery <benjamin.thery@bull.net> writes:
> 
>> Denis V. Lunev wrote:
>>> The patch attached should help. The idea is simple. The "init" should be
>>> called only once without NETNS. Period. No need for any lists.
>> This is the kind of idea I had but I didn't think it could be 
>> that simple. :) 
>> Thanks Denis.
> 
> It isn't.
> 
>>> I'll resend it to Dave after the ACK.
>> Tested on x86_64 with CONFIG_NET_NS=n and y. 
>> It fixes the issue we observed.
>>
>> Acked-by: Benjamin Thery <benjamin.thery@bull.net>
> 
> Try rmmod.

rmmod was part of my tests and it does work.
I did:

$ iptables --list

  modules x_tables, ip_tables & iptable_filter are loaded
  each calling register_pernet_subsys.

$ rmmod iptable_filter ip_tables x_tables

  No problem here

$ iptables --list

  To be sure I can load the modules again.


> 
> Eric
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

   http://www.bull.com
