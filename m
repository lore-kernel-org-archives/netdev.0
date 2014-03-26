From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Wed, 26 Mar 2014 14:17:47 +0100
Message-ID: <20140326131747.GD2869@minipsycho.orion>
References: <532C2AC4.7080303@mojatatu.com>
 <20140322094852.GB2844@minipsycho.orion>
 <5330BAB7.3040501@mojatatu.com>
 <20140325173927.GE8102@hmsreliant.think-freely.org>
 <20140325180009.GB15723@casper.infradead.org>
 <20140325193533.GF8102@hmsreliant.think-freely.org>
 <5331ED86.7020704@mojatatu.com>
 <20140325211945.GC15723@casper.infradead.org>
 <20140326072148.GB2869@minipsycho.orion>
 <5332B365.6050807@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, Neil Horman <nhorman@tuxdriver.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:61409 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130AbaCZNRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 09:17:51 -0400
Received: by mail-ee0-f51.google.com with SMTP id c13so1640784eek.38
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 06:17:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5332B365.6050807@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 26, 2014 at 12:00:53PM CET, jhs@mojatatu.com wrote:
>On 03/26/14 03:21, Jiri Pirko wrote:
>
>>
>>Creating bonding of the switch ports does not fit into the picture at
>>all. These port netdevices are just a representation of a port. Not
>>actual netdevice where the data goes through.
>>
>>Please consider the case I gave already to this thread:
>>
>>         switch chip
>>    ------------------------
>>     |  |  |  |  |  |   |               CPU
>>    p1 p2 ...pn px py  MNGMNT       -----------
>>                 |  |   |              pcie
>>                 |  |   |         ---------------
>>                 |  |   |          |  NIC0 NIC1
>>                 |  |   ---pcie-----   |   |
>>                 |  ------someMII-------   |
>>                 ---------someMII-----------
>>
>>         NIC0 and NIC1 are ordinary NICs like 8139too for example with no
>>         notion they are connected to a switch. They as completely
>>         independent on the mngmnt iface.
>>
>> There, actual data is coming through NIC0 and NIC1 which is
>> completely separated
>> from the p1...pn,px.px port representations.
>>
>> And if you understand it this way, it makes perfect sense to have a
>> master device
>> for these port representations.
>>
>
>I think you may be looking at some specific board design which has those
>two NICs; there are typically many variations of such boards and they
>have to be each dealt with slightly differently by whoever is
>porting. Important detail is:

It is just an example, nothing more.



>we  already know how to deal with NICs - remove them from the diagram
>and then the discussion is about the switch chip. I am assuming
>the MNGMT interface is where the control is going to be. i.e

* I just tried to emphasize where the actual network traffic in between
  switch chip and CPU flows. That is important to realize I believe.


>I can send table updates there, control the different port
>charasterstics etc.
>So Neil's option #1 is to have a driver controlling that interface
>(->priv).
>There's probably some DMA engine's for the datapath for one or more
>of the ports this driver exposes...

See *.

>Replace PCIE with DSA, a simulation chip, whatever the gazillion
>crazy interfaces the openwrt guys have to deal with and we have
>ourselves a consistent interface.
>
>
>>Btw note this model fits into existing DSA as well I believe. The actual DSA
>>devices whould act as NIC0, NIC1 and what would be added is the switch
>>representation (couple of more netdevices to represent actual HW ports and
>>their master)
>>
>
>Refer to my comments above.
>
>
>cheers,
>jamal
>
