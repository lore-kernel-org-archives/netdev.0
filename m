From: Franco Fichtner <franco@lastsummer.de>
Subject: Re: e1000e: reset of tx_queue_len
Date: Tue, 02 Mar 2010 20:52:15 +0100
Message-ID: <4B8D6C6F.9050306@lastsummer.de>
References: <4B8D4E7E.2000805@lastsummer.de> <alpine.WNT.2.00.1003021020160.2888@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.kissl.de ([213.239.241.64]:50098 "EHLO host64.kissl.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750969Ab0CBTtB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Mar 2010 14:49:01 -0500
In-Reply-To: <alpine.WNT.2.00.1003021020160.2888@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandeburg, Jesse wrote:
> On Tue, 2 Mar 2010, Franco Fichtner wrote:
>   
>> while working on a new server, I noticed that tx_queue_len is reset
>> to the default of 1000 while ADDRCONF(NETDEV_CHANGE).
>> This happens with 2.6.30.8, but I could not see any obvious
>> differences to the current state of e1000e, while trying to find the
>> problem in the code.
>>     
>
> The driver tries to set the queuelen back to 1000 if the link changes 
> speed, because the driver tries to shorten the txqueuelen to 100 to reduce 
> latency when the link changes to 100/10 Mb/s
>   

Thanks, that explains it. Since we don't connect ports at startup, the 
plugging causes
a speed "change".

>> The interface has been configured including a customized qlen
>> via /etc/network/interfaces. The ports are not connected at startup
>> so obviously the Kernel reports
>>
>> ADDRCONF(NETDEV_UP): eth2: link is not ready
>>     
>
> do your scripts try to configure the queuelen when link is not up?  Why 
> are the ports not connected at startup?
>   

I have a modified up command that sets appropriate values of mtu and 
qlen via ip. The device is
brought up at startup automatically with the correct values. At least 
that's what ifconfig shows
even though the port is not yet connected.

There has been a lot of testing back and forth with single hosts and 
much larger quantities of traffic.
This got really messy when testing single host first (connected via 100 
Mb/s, so qlen to 100) and then
switching to 1000 Mb/s. qlen would still be 100, causing lots of packet 
drops. This took a few
days to track down, unfortunately.

> Hope this helps

Greatly appreciated, thanks again. :)


Franco
