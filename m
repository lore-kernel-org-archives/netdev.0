From: Ben Greear <greearb@candelatech.com>
Subject: Re: VLAN test cases in 2.6.38.7
Date: Tue, 24 May 2011 17:34:55 -0700
Message-ID: <4DDC4EAF.7090204@candelatech.com>
References: <4DDBFDD6.4060903@candelatech.com> <4DDC0236.4090800@candelatech.com> <4DDC36C4.80408@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53866 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757480Ab1EYAe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 20:34:56 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p4P0Ytj9028836
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 24 May 2011 17:34:55 -0700
In-Reply-To: <4DDC36C4.80408@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/24/2011 03:52 PM, Ben Greear wrote:
> On 05/24/2011 12:08 PM, Ben Greear wrote:
>> On 05/24/2011 11:49 AM, Ben Greear wrote:
>>>
>>> I wrote a simple bridge that uses packet sockets to read/write
>>> from network devices. I'll upload this code somewhere when
>>> I get it a bit more presentable.
>>>
>>> Machine info:
>>>
>>> Linux lf0300-demo 2.6.38.7+ #14 SMP Mon May 23 10:31:45 PDT 2011 i686
>>> i686 i386 GNU/Linux
>>>
>>> Interface A: eth1
>>> driver: igb
>>> version: 3.0.19
>>> firmware-version: 1.2-1
>>> bus-info: 0000:01:00.0
>>>
>>> Interface B: eth3:
>>> driver: igb
>>> version: 3.0.19
>>> firmware-version: 1.2-1
>>> bus-info: 0000:01:00.1
>>>
>>>
>>> If no vlans are on eth1 and eth3, then it bridges fine, with vlan
>>> headers inline. But, if you add a VLAN to eth1, it stops working,
>>> probably because pkt tag is then un-stripped. I was generating on
>>> vlan 7, and created vlan 9, btw.
>>>
>>> I'll see if I can figure out how to use aux-data next...
>>
>> Why does the aux-data mask out the CFI bit? Shouldn't
>> we just pass the 16-bit VLAN tag un-modified to user-space?
>
> Either my ubridge code is broken, or 2.6.38.7+ doesn't send tp_vlan_tci
> properly. All I ever see is zero for that field.
>
> Test case is:
>
> set up VLAN traffic generator on VLAN 7 on separate machine.
> udp traffic, 56kbps, 1024 byte udp payload.
>
> Set up ubridge on test machine:
> ifconfig eth1 promisc
> ifconfig eth3 promisc
> # Make NIC go into stripping mode.
> ip link add link eth1 up name eth1.9 type vlan id 9
> ./do_test.pl eth1 eth3
>
>
> Expect that at least tci is != 0.
>
> The ubridge code is here:
> http://www.candelatech.com/~greearb/misc/ubridge.tar.gz

Ok, was my bug.  That test case passes now...will upload
the fixed code tomorrow.

Ben

>
> Thanks,
> Ben
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

