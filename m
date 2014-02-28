From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] bna: don't disable VLAN tag stripping in promisc mode
Date: Fri, 28 Feb 2014 07:31:42 +0100
Message-ID: <20140228063142.GA2823@minipsycho.orion>
References: <1393525042-7791-1-git-send-email-ivecera@redhat.com>
 <20140227.172403.1870812305847598692.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ivecera@redhat.com, netdev@vger.kernel.org, rmody@brocade.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:43201 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795AbaB1Gbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 01:31:46 -0500
Received: by mail-ea0-f182.google.com with SMTP id b10so1446162eae.13
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 22:31:45 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20140227.172403.1870812305847598692.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 27, 2014 at 11:24:03PM CET, davem@davemloft.net wrote:
>From: Ivan Vecera <ivecera@redhat.com>
>Date: Thu, 27 Feb 2014 19:17:22 +0100
>
>> The recent commit "fe1624c bna: RX Filter Enhancements" disables
>> VLAN tag stripping if the NIC is in promiscuous mode. Received VLAN tagged
>> packets are recognized by the driver via BNA_CQ_EF_VLAN flag and for such
>> packets the driver calls __vlan_hwaccel_put_tag(). The problem is the HW
>> marks the tagged packets with this flags also when the stripping is
>> disabled and thus __vlan_hwaccel_put_tag() should not be called for them.
>> 
>> A solution can be to call __vlan_hwaccel_put_tag() only when stripping is
>> enabled or to leave VLAN stripping engine enabled. The 2nd restores the
>> previous behavior and is IMHO better.
>> 
>> Cc: Rasesh Mody <rmody@brocade.com>
>> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
>
>At best, this is an incomplete change, because if we fix it like this
>then the stripping enable/disable functions are completely unused and
>therefore should be removed from the driver.
>
>But I really thing that checking if stripping is enabled at the
>__vlan_hwaccel_put_tag() call site is the best solution.
>
>You just need to check rxf->vlan_strip_status in addition to the
>descriptor flag.
>
>Please implement it this way, thanks.

Dave, do you think that enabling/disabling of vlan stripping should
depend on promisc on/off? That seems very odd to me...

Jiri

>
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
