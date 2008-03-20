From: Glen Gray <glen.gray@lincor.com>
Subject: Re: r8169 driver fails to see IGMPv2 SAP announcements
Date: Thu, 20 Mar 2008 19:53:35 +0000
Message-ID: <55935F57-5B1B-4F9A-9B37-6236419C6F81@lincor.com>
References: <OF2A1B6BCC.6EDD542B-ON88257412.005C674C-88257412.005EEFF4@us.ibm.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset="US-ASCII"; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.station1.mxsweep.com ([212.147.136.149]:2512 "EHLO
	scmp07.mxsweep.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753578AbYCTT6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 15:58:22 -0400
In-Reply-To: <OF2A1B6BCC.6EDD542B-ON88257412.005C674C-88257412.005EEFF4@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey David,

Thanks for the response. I've posted about this a couple of times over  
the months so probably didn't
explain myself properly this time around.

1) Hardware is Thin Client form factor PC with a Via C7 CPU and with  
Realtek
8110/8169SC used as a custom
    set top box for IPTV/VOD playback.
2) IPTV channels are announced with SAP
3) Using the Realtek r1000/r8169 driver, SAP announcements are  
received and we can generate our playlists for TV channels
    Using any mainline kernel r8169 driver from 2.6.18 to 2.6.24.3,  
the SAP announcements are not picked up on the same
    device, connected to the same switch with the same cables. i.e.  
everything the same, just with different drivers.
4) Realtek driver proved to be unstable. Francois kindly provided a  
patch last summer to work around the major issues
    while investigating why SAP wasn't being detected using the  
mainline kernel, but by his own admittance it was low on his
    radar at the time. While the patch for the Realtek driver improved  
things in our test lab, the site was still seeing
    issues where the units would "fall off the network" i.e. the units  
would be active, but would stop receiving network traffic.
    This only happens after prolonged up times and seemed to be  
triggered by a channel change (i.e. subscribing to a new multicast  
address).
5) Stress testing of the units with the Realtek r1000/r8169 driver  
showed us that
    a) Playing many different 4.5Mbps unicast rtsp streams over and  
over again for a week showed no issues what so ever
    b) Playing various multicast streams in sequence, changing every  
30 seconds, resulted in visual artifacts after about an hour
       and after 2 to 3 hours most of the streams where unwatchable. A  
different hardware platform, running the same software stack
       connected to the same switch and running the same test, showed  
no issues.
6) Previous tests with tcpdump showed that the appropriate ethernet  
multicast packets weren't coming in, see my original post about
    this from July 2007 while testing on a 2.6.22.1 kernel, http://www.mail-archive.com/netdev@vger.kernel.org/msg42967.html


This issue has plagued us for a long time. The issue has given us a  
black eye with the customer due to stability problems with the Realtek  
driver
I'd really like to replace that with a fully functional main-line  
kernel.

On 20 Mar 2008, at 17:17, David Stevens wrote:
>> The SAP announcements are made via IGMPv2, however the eth0 device
>> comes up as IGMPv3 and so doesn't pick up the announcements. I've  
>> used
>> the proc interface force_igmp_version to set all devices to v2, but  
>> it
>> doesn't seem to make any difference.
>
> Glen,
>        I don't really know what you're reporting here. If by "doesn't
> seem to make any difference" you mean that you still get v3 reports
> when force_igmp_version=2, that would be news to me, and a packet
> trace demonstrating that on a mainline kernel would be good.
>        If you mean it doesn't fix your data loss problem, then I'd
> just conclude that the loss has nothing to do with IGMP reports.
>
>        I think the things of interest to look at are whether the
> sender side is sending SAP announcements when the failure occurs and
> whether the multicast router ever drops membership when you think
> it shouldn't during a failure. You can use "tcpdump" on the sender
> side to track these, and your multicast router may have some
> logging capability to let you know state changes of interest. I
> recommend looking at those (or posting here, size permitting) to
> narrow down the problem.
>
>                                                                +-DLS
>

