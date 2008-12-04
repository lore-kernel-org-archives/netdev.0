From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 07/39] wimax: generic WiMAX device management (registration,
 deregistration, etc)
Date: Thu, 04 Dec 2008 14:02:46 +0100
Message-ID: <4937D4F6.6040506@trash.net>
References: <cover.1227691434.git.inaky@linux.intel.com> <8b18de7322859679eefc5e9f1a86249d41762140.1227691434.git.inaky@linux.intel.com> <492E793A.7020501@trash.net> <200812021806.36819.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60923 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649AbYLDNCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 08:02:49 -0500
In-Reply-To: <200812021806.36819.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inaky Perez-Gonzalez wrote:
> On Thursday 27 November 2008, Patrick McHardy wrote:
>>>
>>> +	result = nla_put_u64(reply_skb, WIMAX_GNL_RESULT_CODE, (u64) code_s64);
>>> +	if (result < 0)
>>> +		dev_err(dev, "Error putting attribute: %d\n", result);
>> This is not how netlink protocols should treat errors.
>> It should return -ENOSPC (everywhere else also of course).
> 
> Other than the fact that this function is gone after Johannes comments
> (so for everywhere else), wouldn't returning the -EMSGSIZE nla_put_*() 
> returns enough?
> 
> I changed all of them to be something like:
> 
> result = nla_put*();
> if (result < 0)
> 	goto error path /* release skb/msg, return result */

That looks fine.
