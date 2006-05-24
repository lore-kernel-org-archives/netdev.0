From: Brian Haley <brian.haley@hp.com>
Subject: Re: reminder, 2.6.18 window...
Date: Wed, 24 May 2006 16:44:23 -0400
Message-ID: <4474C5A7.2070703@hp.com>
References: <20060523.182217.59656237.davem@davemloft.net>	 <447412CA.50303@ipom.com> <4474A489.4080308@garzik.org>	 <20060524185644.GF22881@ipom.com> <4474AE92.3030501@garzik.org>	 <20060524191442.GG22881@ipom.com> <1148501433.5325.52.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Phil Dibowitz <phil@ipom.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel7.hp.com ([156.153.255.213]:30081 "EHLO atlrel7.hp.com")
	by vger.kernel.org with ESMTP id S932372AbWEXUo0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 16:44:26 -0400
To: hadi@cyberus.ca
In-Reply-To: <1148501433.5325.52.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Wed, 2006-24-05 at 12:14 -0700, Phil Dibowitz wrote:
> 
>>Right, I'm aware there are other ways of doing this - I've written scripts to
>>record a hundreds of numbers, and then subtract them from each other. But
>>those scripts are work arounds 

I don't have any problem with Phil's changes.

> It is not a work around, _it is design intent_. It is what network
> management tools have been expecting since the days of the caveman.
> These stats are supposed to be monotonically increasing; if that
> behavior is contradicted, a rollover of the counters is assumed.

So how is this different than if an SNMP station probes my system, then 
I reboot, then they probe again.  Things will seem to have gone 
backwards, but they deal with that just fine.

>>for a feature _lacking_ in the kernel. A
>>feature that, as I've mentioned, is supported on any piece of networking gear
>>(and of course, lets not forget there's a specific option in the kernel config
>>*just* for "behave like a router").
> 
> 
> Can you provide some link to a vendor that allows resetting ethernet
> stats? I am almost certain, if they do they will have something or other
> which indicates that such a reset happened.

DEC/Compaq/HP has allowed this on Tru64 UNIX since 1999 because we had 
customers that wanted it, noone ever complained about complications with 
SNMP.  We did save the last time the stats were zero'd in the struct for 
posterity, but that was never get-able via SNMP:

--> netstat -I tu0 -s

tu0 Ethernet counters at Wed May 24 16:30:05 2006

           609415 seconds since last zeroed
       3943458720 bytes received
        113576310 bytes sent
...

Maybe saving a "ztime" would make people happier?

> It is also easier for cisco
> to have none standard feature "as of ios 15.16" which could support such
> behavior because they bundle everything including network management
> tools.

I never received any free management tools with my Cisco routers :) , 
they charge big bucks for that stuff!

>>If my patch was invasive and broke things, 
> 
> It _does break_ things for all known management apps.

Can anyone show a management app this breaks?

-Brian
