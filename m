From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 9812] New: Kernel does not deliver packets going
 through the INPUT chain even if the app is listening on IN_ADDR_ANY
Date: Fri, 25 Jan 2008 14:17:48 +0100
Message-ID: <4799E17C.6040803@trash.net>
References: <bug-9812-10286@http.bugzilla.kernel.org/> <20080125051404.3bbefab3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	pawel@rogocz.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38231 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753170AbYAYNSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 08:18:06 -0500
In-Reply-To: <20080125051404.3bbefab3.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
>> On Fri, 25 Jan 2008 03:59:27 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
>> http://bugzilla.kernel.org/show_bug.cgi?id=9812
>>

>> Problem Description:
>>
>> I have a farm of web servers behind a load balancer in DSR mode.
>> I would like to be able to dump packets with any IP address on the web servers
>> through the load balancer and have web servers reply to these requests.
>> Currently for every IP web servers are supposed to reply to, I have to
>> configure the IP on all servers on their loopback interfaces. The web server
>> listens on IN_ADDR_ANY and I am forcing packets into the INPUT chain via
>> iptables/netfilter but the kernel never replies to any connection requests. I
>> only see the counter for OutNoRoutes increasing.
>>
>> Steps to reproduce:
>>
>> web server:
>>
>> #iptables -A PREROUTING -i eth0 -t mangle -p tcp --dport 80 -j MARK --set-mark
>> 1 
>> #ip route add to local default dev lo protocol kernel table 1
>> #ip rule add fwmark 1 table 1 priority 1
>>
>> client:
>>
>> #ip route add 1.1.1.1/32 via <web server IP> dev eth0
>>
>> while making requests to 1.1.1.1:80 from the client you can see increasing
>> OutNoRoutes counter but no connection ever takes place.


I already commented in bugzilla, this is not a bug but an incorrect
setup. DNAT or REDIRECT must be used to make this work properly.

