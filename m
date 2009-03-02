From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: Marvell 88E609x switch?
Date: Mon, 2 Mar 2009 23:05:29 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0903022237580.1863@ask.diku.dk>
References: <20090227145746.GD17040@xi.wantstofly.org>  <49A801E6.1040502@mlbassoc.com>
 <20090227151441.GE17040@xi.wantstofly.org>  <49A80606.1040508@mlbassoc.com>
 <20090227152721.GG17040@xi.wantstofly.org>  <49A806C5.1010200@mlbassoc.com>
 <20090227153102.GH17040@xi.wantstofly.org>  <49A80A75.8000101@mlbassoc.com>
 <20090227155224.GK17040@xi.wantstofly.org>  <Pine.LNX.4.64.0902272211260.19905@ask.diku.dk>
  <20090227222802.GZ17040@xi.wantstofly.org>  <1235991382.30736.62.camel@localhost.localdomain>
 <1235991937.30736.65.camel@localhost.localdomain> <49ABF7DF.8060302@mlbassoc.com>
 <49ABF9A9.2040608@mlbassoc.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: jdb@comx.dk, Lennert Buytenhek <buytenh@wantstofly.org>,
	netdev <netdev@vger.kernel.org>
To: Gary Thomas <gary@mlbassoc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:39982 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752464AbZCBWFf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 17:05:35 -0500
In-Reply-To: <49ABF9A9.2040608@mlbassoc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




On Mon, 2 Mar 2009, Gary Thomas wrote:

> Gary Thomas wrote:
>> Jesper Dangaard Brouer wrote:
>>> On Mon, 2009-03-02 at 11:56 +0100, Jesper Dangaard Brouer wrote:
>>>
>>>> You should write 0x003E ... see attached patch
>>> Ups, I see (from the thread) that you have already done/tried this...
>>>
>>
>> Yes, although I think it will need some work in the future
>> (I've set it to 1000Mb connection, you said you used 100Mb, etc)
>>
>> Question: I'm testing this by trying a ping out of my box.
>> Linux replies by sending an ARP packet out, and the destination
>> replies with an ARP packet in.  I can see from the ethtool stats
>> that the reply packets get into lan1.1 (the physical port I'm
>> using), but I don't see them get moved through the CPU port.

Well, thats a break through :-) If I understand you correctly, the 
destination host actually receives the ARP packet and responds with a 
packet.

That should means that the outgoing DSA tagging is working.  Although I'm 
not sure about the incomming...

>> My understanding is that this should work via the VLAN map?

I think that the "VLAN map/table" has gotten a wrong name as it does not 
really determine the VLANs, it only says who can talk to whom.  The switch 
does support a real vlan setup, but its deactivated in Lennerts driver, as 
I guess he wants Linux to handle the VLANs.  (I use the real VLAN setup 
extensively in my driver).

>> I checked that setup and it looks OK.

I have also checked the different registers setting, and things looks 
quite alright.  Although I'm missing the register datasheets for the 6131 
chip, I found that I only have part 1 of 3 crap...

I did find that the 6095 and 6097 does differ in the way DSA handling is 
done, as the 6097 supports Ethertype DSA and 6095 don't.  But the 6131 
driver looks like it does the right thing for the 6095.


>> Any ideas where this might be going wrong?

Is lan1.1 up and have you given it an IP address?
(could I get a 'ifconfig' output?)

Are you sending packets with VLAN tags?


> I also just noticed that the ESA registers (Global 1,2,3)
> aren't set at all.  I'm pretty sure that the way I'm using
> the switch in my bootloader this doesn't matter as all packets
> have a fixed routing and the ESA recognition happens at the
> actual ethernet device.

Don't think the switch needs a MAC address...

> Is this going to cause problems with the VLAN (+DSA) based
> routing?

Don't think so...

Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
