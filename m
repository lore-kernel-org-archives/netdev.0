From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] inetpeer: Add support for VRFs
Date: Tue, 25 Aug 2015 13:47:59 -0700 (PDT)
Message-ID: <20150825.134759.1592811364914291771.davem@davemloft.net>
References: <1440339964-16075-1-git-send-email-dsa@cumulusnetworks.com>
	<20150824001514.GD21926@pox.localdomain>
	<55DA7AFE.5040301@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, shm@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59450 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752291AbbHYUsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 16:48:00 -0400
In-Reply-To: <55DA7AFE.5040301@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Sun, 23 Aug 2015 20:01:34 -0600

> On 8/23/15 6:15 PM, Thomas Graf wrote:
>> On 08/23/15 at 08:26am, David Ahern wrote:
>>> inetpeer caches based on address only, so duplicate IP addresses
>>> within
>>> a namespace return the same cached entry. Similar to IP fragments
>>> handle
>>> duplicate addresses across VRFs by adding the VRF master device index
>>> to
>>> the lookup.
>>
>> We have a lot of other places which use the address only. Are you
>> going to add the VRF id to all these places as well?
>>
> 
> If appropriate, yes. I have fixed IP fragments and this patch fixes
> inetpeer cache. In both cases (L3 artifacts) the vrf device index
> provides the means to uniquely identify duplicate IP addresses within
> a namespace. If you know of other code that might be impacted I will
> investigate and fix as needed.

Anyways, what this inetpeer patch is doing is the wrong abstraction.

The key is really "daddr + netdev" so make a helper that works using
those arguments.

Then it is clear as we propagate this around that addresses need to
be coupled with the device in question in order to be keyed properly.
