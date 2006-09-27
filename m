From: David Acker <dacker@roinet.com>
Subject: Re: mii-tool gigabit support.
Date: Wed, 27 Sep 2006 16:26:06 -0400
Message-ID: <451ADE5E.8000601@roinet.com>
References: <20060926145113.7a6791c8@freekitty>	<4519A1D6.1050802@pobox.com>	<20060926150947.3d538547@freekitty> <451A7603.1030204@roinet.com> <451AAFFE.2020607@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Jeff Garzik <jgarzik@pobox.com>, dhinds@pcmcia.sourceforge.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-64-105-159-118.phlapafg.covad.net ([64.105.159.118]:55704
	"EHLO smtp.roinet.com") by vger.kernel.org with ESMTP
	id S1030759AbWI0U0N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 16:26:13 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <451AAFFE.2020607@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
>> With mii-tool we can do the command below and work with a half duplex 
>> hub and a full duplex switch.
>> mii-tool -A 10baseT-FD,10baseT-HD eth0
> 
> Why, and how often, is that really necessary?
> 
> rick jones
> 

Take a wifi router with only 802.11b radios and ethernet chips that do 
not support handling DMA to host memory.  In this case receives from 
ethernet cost a lot since the packets must be read into host memory by 
the CPU (instead of written there by the adapter).  Also, receiving 100 
Mbit in when you only have 802.11b pipes out isn't terrible useful.  UDP 
blasts from ethernet can hog the CPU and with some NICs cause soft lockups.

We could just set it to 10Mbit half duplex always but two 802.11b radios 
can saturate that with bidirectional traffic.  We have seen failures to 
send due to collisions.  Thus, we would like to be able advertise 10Mb 
full and half duplex so that we can get the appropriate speed when that 
the neighbor device supports.  We have seen various ethernet switches or 
NICs (like IP video cameras with ethernet) that will not run 10Mb full 
duplex but will do 100Mb full or 10Mb half.

We want it to be configurable at run time since sometimes the same 
software may run on a system that has 802.11G radios and and perhaps 
more capable ethernet devices.  We can detect our situation in our 
startup script and adjust the advertised speeds down only when needed.

-Ack
