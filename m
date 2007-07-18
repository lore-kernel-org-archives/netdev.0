From: Ben Greear <greearb@candelatech.com>
Subject: Re: Linux, tcpdump and vlan
Date: Wed, 18 Jul 2007 16:22:57 -0700
Message-ID: <469EA0D1.6020406@candelatech.com>
References: <878246.51044.qm@web56608.mail.re3.yahoo.com> <469E9AC8.3090603@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andrei radulescu-banu <iubica2@yahoo.com>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:33309 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756941AbXGRXXA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2007 19:23:00 -0400
In-Reply-To: <469E9AC8.3090603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> andrei radulescu-banu wrote:
>   
>> [...]
>>
>> In conclusion, here is the buglist:  
>> 1). If set promiscuous, the e1000 should disable any vlan rx filtering, so that it can receive vlan frames of other vlan id's. Other ethernet drivers probably need fixed as well.
>>   2). The packet layer should change the rx skb device from the vlan 'fake' device (eth0.2) to the corresponding physical device (eth0), so when we run tcpdump on eth0 we see all vlan-tagged and non-vlan-tagged frames
>>   3). The packet socket layer should insert the vlan tag header before passing frames to the upper layer, so tcpdump can display them.
>>     
> Put another way, once you enable VLAN header stripping, you
> won't see the headers for *any* VLAN, not only for those you're
> actually running locally. This is also a problem for devices
> like macvlan, where it would be desirable to make use of
> hardware VLAN accerlation. I was thinking about storing the
> information somewhere in the packets meta-data on both RX and
> TX paths, that would also allow tcpdump to properly display
> packets.
>   
MAC-VLAN could gather this information based on it's parent
device (ie, if parent-dev has VID 7, then add VID 7 to the meta
data.  There would be no need for any driver changes I think.

Other than TCP-dump, or some other raw protocol that wants to see
the VLAN header in user-space, I can't think of what use this would
be, however.  And, if you just disable VLAN accel in the NIC (see below),
that would make this mac-vlan hackery not needed at all?
> I have planned to look into this when I find some time.
> Your suggestion of disabling VLAN acceleration in promiscous
> mode sounds like a reasonable solution until then ..
>   
I think a better method would be to allow disabling VLAN HW accel for a 
NIC with
ethtool.  Then, the packets will be received by the software stack with 
the vlan
header intact.  Something sniffing on the physical dev will 
automatically get the
VLAN header.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


