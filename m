From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] tcp: randomize TCP source ports
Date: Fri, 08 Nov 2013 15:26:24 -0800
Message-ID: <527D7320.4050008@hp.com>
References: <1383872049.9412.124.camel@edumazet-glaptop2.roam.corp.google.com> <527C3942.509@hp.com> <1383876294.9412.136.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:23152 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757954Ab3KHX00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 18:26:26 -0500
In-Reply-To: <1383876294.9412.136.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/07/2013 06:04 PM, Eric Dumazet wrote:
> On Thu, 2013-11-07 at 17:07 -0800, Rick Jones wrote:
>
>> For perhaps most definitions of well deployed.  There is at least one
>> load balancer which, while it offers TCP Window Scaling, does not also
>> offer TCP Time Stamps...
>>
>> By rights they should (must) be offering TCP Time Stamps, and they are,
>> I am told, "working on it."
>>
>> Is all going to be "well" when it is the (non-Linux) remote system which
>> has the TIME_WAIT endpoint?
>
> Hey, tell us why netperf does a bind(port=0, addr=ANY) and SO_REUSEADDR
> tricks before connect()
>
> It seems you do request randomization, but you do not want it for
> applications written by innocent people...

That bind() call is not there to request randomization of the TCP source 
port.

The bind() call in src/nettest_bsd.c/create_data_socket() is so 
netserver can report a port number back to netperf.  It is also there so 
a TCP_CRR test can explicitly use more than the configured ephemeral 
port range.  It is also used when setting explicit port numbers for 
getting through firewalls.

In the establish_control() path the bind() call is also there to allow 
specifying an explicit port number for the control connection.  I just 
don't bother avoiding the call when someone hasn't selected an explicit 
client-side port number for the control connection.

happy benchmarking,

rick jones
