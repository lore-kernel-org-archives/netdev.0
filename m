From: Vivek Kashyap <kashyapv@us.ibm.com>
Subject: Re: [net-next-2.6 PATCH 2/2] add ndo_set_port_profile op support
 for enic dynamic vnics
Date: Sun, 2 May 2010 21:29:10 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.1005022119140.16925@vk>
References: <C7FEE68A.2CBEF%scofeldm@cisco.com> <201004291748.38702.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Scott Feldman <scofeldm@cisco.com>, davem@davemloft.net,
	netdev@vger.kernel.org, chrisw@redhat.com,
	Jens Osterkamp <Jens.Osterkamp@gmx.de>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:35075 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868Ab0ECE31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 00:29:27 -0400
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e38.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o434NBin009479
	for <netdev@vger.kernel.org>; Sun, 2 May 2010 22:23:11 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o434TQpS131912
	for <netdev@vger.kernel.org>; Sun, 2 May 2010 22:29:26 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o42LTOkx015927
	for <netdev@vger.kernel.org>; Sun, 2 May 2010 15:29:25 -0600
In-Reply-To: <201004291748.38702.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
>>>>    ip port_profile set DEVICE [ base DEVICE ] [ { pre_associate |
>>>>                                                   pre_associate_rr } ]
>>>>                               { name PORT-PROFILE | vsi MGR:VTID:VER }
>>
>> BTW, I was meaning to ask: is there a way to role the vsi tuple and the
>> flags up into a single identifier, say a string like PORT-PROFILE?  I'm
>> asking because it seems awkward from an admin's perspective to know how to
>> construct a vsi tuple or to know what pre_associate_rr means. I have to
>> admit I didn't fully grok what pre_associate_rr means myself.  Even if there
>> was a simple local database to map named port-profiles to the underlying
>> {vsi tuple, flags}, that would bring us closer to a more consistent user
>> interface.  Is this possible?
>
> I think that's technically possible but may not be helpful to make the
> user interface easier. Some background on pre-associate:
>
> The purpose of this is to assist guest migration. A single VSI (i.e. guest
> network adapter) may only be connected to a single switch port at any
> given time. The VSI is identified by its UUID and it has a unique
> MAC address.
>
> When migrating a guest to a new hypervisor, we need to ask the switch
> to associate that VSI at the destination switch port (which may or may
> not be on the same different switch as the source port). This operation
> may fail for a number of reasons and can take some time. Since we want
> migration to alway succeed and take as little time as possible, we
> do a pre-associate-with-resource-reservation before the migration and
> only start the actual guest migration if that completes successfully.
>
> After a successful pre-associate-with-resource-reservation step, we
> know that the actual associate step will be both fast and successful.
> After it completes, the VSI is known to be on the destination
> and all traffic goes there (replacing the gratuitous ARP method we do
> today).
>
> I don't think we'd ever do a pre-associate without the
> resource-reservation, but the standard defines both. In theory,
> we could do a pre-associate at every switch in the data center
> in order to find out if it's possible to migrate there.
>
> If you want to have more details, please look at the draft spec at
> http://www.ieee802.org/1/files/public/docs2010/bg-joint-evb-0410v1.pdf

The basic difference is that in 'pre-associate with resoruce reservation', the 
local buffers and resources needed for the eventual 'associate' are reserved
at the switch port.  Therefore the associate will not fail with 
'insufficient resources'. It might otherwise.

thanks
 	Vivek

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
