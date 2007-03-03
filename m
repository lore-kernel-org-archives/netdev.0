From: Ben Greear <greearb@candelatech.com>
Subject: Re: ppp and routing table rules.
Date: Fri, 02 Mar 2007 23:22:20 -0800
Message-ID: <45E9222C.4090504@candelatech.com>
References: <45E7AC31.9030309@candelatech.com>	<45E7C45F.9080805@candelatech.com> <20070303005455.86dd8059.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:40576 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751197AbXCCHUV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Mar 2007 02:20:21 -0500
In-Reply-To: <20070303005455.86dd8059.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bill Fink wrote:
> On Thu, 01 Mar 2007, Ben Greear wrote:
>
>   
>> Ben Greear wrote:
>>
>> I am sending udp packets through ppp400, and I see them appear on ppp401 
>> as expected.
>>
>> The thing that is bothering me is that all I see on rddVR4 (172.1.2.1) 
>> is arps for 172.1.2.2, but the 'tell' IP is that of the
>> originating ppp400 link, not the IP of rddVR4, as I expected:
>>
>> 21:47:16.119640 arp who-has 172.1.2.2 tell 11.1.1.3
>> 21:47:17.119371 arp who-has 172.1.2.2 tell 11.1.1.3
>> 21:47:18.119254 arp who-has 172.1.2.2 tell 11.1.1.3
>> 21:47:19.273118 arp who-has 172.1.2.2 tell 11.1.1.3
>>
>> Unless I'm missing something dumb, a similar setup with all ethernet-ish 
>> network devices
>> works fine.
>>
>> I have also enabled arp filtering:
>> # Only answer ARPs if it is for the IP on our own interface.
>> echo 2 > /proc/sys/net/ipv4/conf/all/arp_ignore
>> and for every device used in these routing tables:
>> echo 1 > /proc/sys/net/ipv4/conf/[dev]/arp_filter
>>
>> Any idea what I need to do in order to make  the source IP for the ARP 
>> packet correct?
>>     
>
> Wouldn't that be controlled by arp_announce?
>   

Yes, after trawling through the code I found that one, and setting it to '2'
seems to have fixed everything.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


