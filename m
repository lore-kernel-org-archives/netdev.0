From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net] bna: don't disable VLAN tag stripping in promisc
 mode
Date: Fri, 28 Feb 2014 10:09:18 +0100
Message-ID: <5310523E.80506@redhat.com>
References: <1393525042-7791-1-git-send-email-ivecera@redhat.com> <20140227.172403.1870812305847598692.davem@davemloft.net> <20140228063142.GA2823@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rmody@brocade.com
To: Jiri Pirko <jiri@resnulli.us>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4989 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751495AbaB1JJZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Feb 2014 04:09:25 -0500
In-Reply-To: <20140228063142.GA2823@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/28/2014 07:31 AM, Jiri Pirko wrote:
> Thu, Feb 27, 2014 at 11:24:03PM CET, davem@davemloft.net wrote:
>> From: Ivan Vecera <ivecera@redhat.com>
>> Date: Thu, 27 Feb 2014 19:17:22 +0100
>>
>>> The recent commit "fe1624c bna: RX Filter Enhancements" disables
>>> VLAN tag stripping if the NIC is in promiscuous mode. Received VLAN tagged
>>> packets are recognized by the driver via BNA_CQ_EF_VLAN flag and for such
>>> packets the driver calls __vlan_hwaccel_put_tag(). The problem is the HW
>>> marks the tagged packets with this flags also when the stripping is
>>> disabled and thus __vlan_hwaccel_put_tag() should not be called for them.
>>>
>>> A solution can be to call __vlan_hwaccel_put_tag() only when stripping is
>>> enabled or to leave VLAN stripping engine enabled. The 2nd restores the
>>> previous behavior and is IMHO better.
>>>
>>> Cc: Rasesh Mody <rmody@brocade.com>
>>> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
>>
>> At best, this is an incomplete change, because if we fix it like this
>> then the stripping enable/disable functions are completely unused and
>> therefore should be removed from the driver.
>>
>> But I really thing that checking if stripping is enabled at the
>> __vlan_hwaccel_put_tag() call site is the best solution.
>>
>> You just need to check rxf->vlan_strip_status in addition to the
>> descriptor flag.
>>
>> Please implement it this way, thanks.
>
> Dave, do you think that enabling/disabling of vlan stripping should
> depend on promisc on/off? That seems very odd to me...
>
> Jiri
>
You are right both. The VLAN stripping should not depend on promisc mode 
and the functions should not be unused.
My idea was to fix the regression by reverting of problematic part of 
offending commit and to use the helper function to implement the VLAN 
tag strip toggling.

I have prepared the 2nd version that implements the above functionality.

Ivan
