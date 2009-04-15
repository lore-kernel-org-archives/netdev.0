From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Wed, 15 Apr 2009 17:04:36 -0400
Message-ID: <49E64BE4.1050908@myri.com>
References: <20090415100937.4b08ce28@dhcp-lab-109.englab.brq.redhat.com>	<20090415.022809.90182032.davem@davemloft.net>	<49E5AD56.6020701@myri.com> <20090415.030213.249634462.davem@davemloft.net> <49E5DABB.9070806@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: brice@myri.com, sgruszka@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1929 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752307AbZDOVEz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2009 17:04:55 -0400
In-Reply-To: <49E5DABB.9070806@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Gallatin wrote:
> David Miller wrote:
>> From: Brice Goglin <brice@myri.com>
>>> Is there a good summary somewhere of why GRO is better,
>>
>> Transparent forwarding/bridging support, easier driver port.
>>
>>> and how to
>>> actually convert drivers?
>>
>> Step 1: Remove all of your LRO support code, every last line
>> Step 2: netif_receive_skb() --> napi_gro_receive()
>>         vlan_hwaccel_rx() --> vlan_gro_receive()
>>
>> It couldn't be any easier.
>>
>> And it would also behoove you to look at the commits that converted or
>> added GRO support to other drivers.  That's how I learned it :-)
> 
> Unfortunately, it doesn't appear that GRO is able to handle frags
> (like lro_receive_frags()), so I anticipate its overhead would

Ah, I missed napi_gro_frags()!   I've got quick and dirty test
patch which uses that, but I need to fix a few things. I also need
to figure out why it seems to be a bit slower than LRO
(varies from 8.5 to 9.2 Gb/s, rather than always 9.4Gb/s)
on my old, weak 2.0GHz athlon64.

Thanks for the pointer,

Drew
