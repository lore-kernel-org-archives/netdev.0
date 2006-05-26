From: Rick Jones <rick.jones2@hp.com>
Subject: Re: reminder, 2.6.18 window...
Date: Fri, 26 May 2006 15:06:16 -0700
Message-ID: <44777BD8.1040503@hp.com>
References: <20060523.182217.59656237.davem@davemloft.net>	<447412CA.50303@ipom.com>	<4474A489.4080308@garzik.org>	<20060524185644.GF22881@ipom.com>	<4474AE92.3030501@garzik.org>	<20060524191442.GG22881@ipom.com>	<1148501433.5325.52.camel@jzny2>	<4474C12E.8050600@hp.com>	<1148570852.5283.23.camel@jzny2> <4475DEA2.3090201@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Jeff Garzik <jeff@garzik.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Phil Dibowitz <phil@ipom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:6637 "EHLO palrel10.hp.com")
	by vger.kernel.org with ESMTP id S1750947AbWEZWGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 May 2006 18:06:21 -0400
To: Rick Jones <rick.jones2@hp.com>
In-Reply-To: <4475DEA2.3090201@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Can you ask internally on how openview would handle this? It carriers 
>> the major chunk of management tools market so it may provide good 
>> insight.
> 
> 
> I've asked the question in an internal, informal communications channel. 
>  No guarantees it will reach any OpenView types, but if it does I'll try 
> to provide the gist of the replies.

While the question of the patch itself appears to be laid to rest for 
the time being, since I took an "action item" I figured it would be good 
to complete it.

Here was one response:

> If the stats are being gathered via SNMP, most management systems do
> one of two things:
> 
> - treat it as a discontinuity: in this case, the handling is similar
>   to that for a device reboot; that is, delta calculation starts anew.
> 
> - treat it as a wrap-around (especially for 32-bit counters): the smarter
>   ones have logic to detect whether this is a "feasible" wrap-around (e.g.,
>   old measurement was "near" overflow, etc.) and appropriately adjust
>   the delta.
> 
> In your case, it looks like you want to treat this as a discontinuity.
> The interface table in IF-MIB has an attribute called ifLastChange; if
> you reset the counter, you may want to set it to the sysUpTime value.
> This way, a "proper" implementation could determine that a
> discontinuity has occurred.

And then a more detailed response with an associated, and very long URL:

<excerpt>

http://openview.hp.com/ecare/getsupportdoc?docid=OV-EN012963&urlN=http%3A%2F%2Fsupport.openview.hp.com%2Fselfsolve%2Fdo%2Fadvanced-search&fromOV
=false&urlB=http%3A%2F%2Fsupport.openview.hp.com%2Fselfsolve%2Fdo%2Fadvanced-search%3Faction%3Dresults&f=ss&hl=true

QUOTE:

This problem can be caused by the SNMP MIB counter wrap.  NNM 6.01 or
later has logic to detect collected MIB counter wrap.

If NNM detects that a MIB counter is wrapped, then it is considered as
one of the following two cases:

The counter reached its maximum value and wrapped.
The counter reset occurred due to the SNMP agent restart.
In the case of (1), snmpCollect takes the counter wrap into account and
adjusts the value taking the maximum value of the counter into
consideration.  However, in the case of (2), NNM cancels the measurement
of this period because it considers that the previous value that was
used for calculation is no longer valid.

If the value of the counter increases too fast, NNM may consider that
the detected counter wrap is due to the agent restart even though the
counter just wrapped.  In this case, the data of the measurement period
gets dropped.

There are two approaches available to avoid this situation:

Use counters that have a larger maximum size.  For example, use
IfHCInOctets/IfHCOutOctets(64bit - counter64) in IF_MIB instead of
IfInOctets/IfOutOctets(32bit - counter).
Shorten the period of measurement, so that the amount of the counter
increase is potentially short enough to let NNM detect the counter wrap
correctly.

Note:
It may be necessary to upgrade the operating system of some network
devices to gain access to 64-bit counters. Note also, that counter64 is
a SNMPv2 data type, the agent must support SNMPv2. If trying to access
the values using snmpwalk  use the parameter-v2c to ensure that the
variables can be accessed.

</excerpt>

rick jones
