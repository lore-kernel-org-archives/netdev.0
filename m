From: Rick Jones <rick.jones2@hp.com>
Subject: Re: specifying scopid's for link-local IPv6 addrs
Date: Tue, 24 Jul 2007 10:23:02 -0700
Message-ID: <46A63576.5050908@hp.com>
References: <46A4FAFF.8010809@hp.com>	<20070724030115.3208229d.billfink@mindspring.com> <46A63327.6010705@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bill Fink <billfink@mindspring.com>
To: Linux Network Development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:48858 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751447AbXGXRaG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 13:30:06 -0400
In-Reply-To: <46A63327.6010705@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>> You must explicitly specify the desired interface.  For example,
>> on my test system, the correct interface is eth6 which is interface 8
>> (lo eth0 eth1 eth2 ... eth5 eth6).  Here is an example nuttcp test
>> specifying interface 8:
>>
>> chance% nuttcp -P5100 fe80::202:b3ff:fed4:cd1%8
>>  1178.5809 MB /  10.02 sec =  986.2728 Mbps 12 %TX 15 %RX
>>
>> nuttcp uses getaddrinfo() which parses the "%<ifindex>" field,
>> and then copies the sin6_scope_id from the res structure to the
>> server's sockaddr_in6 structure before initiating the connect().
> 
> 
> OK, I'll give that a quick try with netperf:
> 
> [root@hpcpc106 ~]# netperf -H 192.168.2.107 -c -C -i 30,3 -- -s 1M -S 1M 
> -m 64K -H fe80::207:43ff:fe05:9d%2
> TCP STREAM TEST from ::0 (::) port 0 AF_INET6 to 
> fe80::207:43ff:fe05:9d%2 (fe80::207:43ff:fe05:9d) port 0 AF_INET6 : 
> +/-2.5% @ 99% conf.
> 
> Cool - it establishes the data connection just fine.

Well, I spoke too soon - while it got me past my EINVAL, the connection 
establishement timed-out.  Either I picked the wrong value for n, or I may yet 
need to make some tweaks to netperf.

rick jones
