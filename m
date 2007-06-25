From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Mon, 25 Jun 2007 10:35:14 -0700
Message-ID: <467FFCD2.30908@hp.com>
References: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com>	<1181216629.4064.22.camel@localhost>	<20070619132148.GA32078@2ka.mipt.ru>	<1182459607.6096.31.camel@raj-laptop> <20070622095935.GA14207@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Krishna Kumar2 <krkumar2@in.ibm.com>,
	Gagan Arneja <gaagaan@gmail.com>, netdev@vger.kernel.org,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:56261 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751343AbXFYRfV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2007 13:35:21 -0400
In-Reply-To: <20070622095935.GA14207@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Thu, Jun 21, 2007 at 02:00:07PM -0700, Rick Jones (rick.jones2@hp.com) wrote:
> 
>>>Simple test included test -> desktop and vice versa traffic with 128 and
>>>4096 block size in netperf-2.4.3 setup.
>>
>>Is that in conjunction with setting the test-specific -D to set
>>TCP_NODELAY, or was Nagle left-on?  If the latter, perhaps timing issues
>>could be why the confidence intervals weren't hit since the relative
>>batching of 128byte sends into larger segments is something of a race.
> 
> 
> I used this parameters:
> netperf -l 60 -H kano -t TCP_STREAM -i 10,2 -I 99,5 -- -m 128 -s 128K
> -S 128K

You can take -i up to 30 for the max count if you want to try to hit the 
levels.

> 
> so without nodelay.
> 
> With nodelay I've gotten:
> batch-128: 128.91 mbit/sec
> mainline-128: 140.57 mbit/sec
> 
> which is about 5 times less than withouth nodelay (~760 mbit/s)
> Although nodelay results look more realistic.

all that fun send batching that happens without nodelay :)

rick jones

> 
> 
> 
>>rick jones
> 
> 

