From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: pktgen question
Date: Mon, 24 Sep 2007 08:54:13 -0500
Message-ID: <46F7C185.1030202@opengridcomputing.com>
References: <46F6905C.6030309@opengridcomputing.com>	 <20070923172803.GA11997@2ka.mipt.ru>	 <46F6A887.1030301@opengridcomputing.com> <1190571527.4256.78.camel@localhost> <46F75968.4010307@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	netdev@vger.kernel.org, Robert Olsson <Robert.Olsson@data.slu.se>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:34226 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751464AbXIXNyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 09:54:13 -0400
In-Reply-To: <46F75968.4010307@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I think pktgen should be cloning the skbs using skb_clone().  Then it 
will work for all devices, eh?


Ben Greear wrote:
> jamal wrote:
>> On Sun, 2007-23-09 at 12:55 -0500, Steve Wise wrote:
>>
>>  
>>> Its a hack that breaks cxgb3 because cxgb3 uses the skb->cb area for 
>>> each skb passed down.  So cxgb3 is at fault then?  IE a driver cannot 
>>> use the skb->cb field if the users count is > 1?  Or maybe a driver 
>>> can _never_ use the cb field?
>>>     
>>
>> any layer can use the cb structure whichever way they wish. There are
>> violations, e.g:
>> the vlan code also uses the cb field to pass vlan details for hardware
>> acceleration. How does pktgen affect it though, clone() will just copy
>> the cb field and pktgen doesnt touch it.
>> In retrospect, pktgen may have to use clone - ccing Robert Olsson.
>>   
> Pktgen abuses the ref count, as far as I can tell.  It works with most 
> ethernet drivers,
> but that multi-pkt will also fail with things like vlans because the 
> skb->dev is changed
> as it is transmitted (to the lower-level device).
> 
> I'd say just don't use the multi-pkt with pktgen on devices that can't 
> handle it.
> 
> Thanks,
> Ben
> 
> 
