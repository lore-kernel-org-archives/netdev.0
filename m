From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [ethtool PATCH] ethtool: Support n-tuple filter programming
Date: Thu, 25 Feb 2010 21:26:38 -0500
Message-ID: <4B87315E.4080905@garzik.org>
References: <20100204075101.16661.95658.stgit@localhost.localdomain> <4B85F173.40703@garzik.org> <Pine.WNT.4.64.1002251739130.51452@ppwaskie-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:46053 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935018Ab0BZC0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 21:26:42 -0500
Received: by gwj16 with SMTP id 16so2143733gwj.19
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2010 18:26:41 -0800 (PST)
In-Reply-To: <Pine.WNT.4.64.1002251739130.51452@ppwaskie-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/25/2010 08:49 PM, Waskiewicz Jr, Peter P wrote:
> On Wed, 24 Feb 2010, Jeff Garzik wrote:
>
>> On 02/04/2010 02:51 AM, Jeff Kirsher wrote:
>>> From: Peter Waskiewicz<peter.p.waskiewicz.jr@intel.com>
>>>
>>> Program underlying ethernet devices with n-tuple flow classification
>>> filters.
>>>
>>> This also adds a new flag to ethtool_flags, allowing n-tuple
>>> programming to be toggled using the set_flags call.
>>>
>>> Signed-off-by: Peter P Waskiewicz Jr<peter.p.waskiewicz.jr@intel.com>
>>> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
>>> ---
>>>
>>>    ethtool-copy.h |   35 +++++++++++++
>>>    ethtool.c      |  156 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
>>>    2 files changed, 186 insertions(+), 5 deletions(-)
>>
>> applied, but two problems remain:
>>
>> 1) you failed to document this in the man page.  I will expect a patch
>> to ethtool.8.
>>
>> 2) you introduced a deviation from the upstream kernel ethtool.h:
>
> The way I've come up with to fix this is less intrusive than I want, but I
> think it's right way to do it.  The intent wasn't to have ethtool
> (userspace) enforce how many filters could be returned.  What it should do
> is get the number of strings through drvinfo to make the proper memory
> allocation.
>
> What I need to change is the drvinfo struct in the kernel to include the
> ethtool strings field, returned from get_sset_count().  Then I can pull
> that into userspace and make the correct memory allocation, then call
> get_rx_ntuple().

I would say we need a ETHTOOL_GSTRINGS_COUNT rather than expanding 
drvinfo anymore...  but yeah, expanding drvinfo would work too.


> This will require a small kernel change.  Will something like this be
> pulled in at this point, given that 2.6.33 just released?

The n-tuple stuff is not in 2.6.33's ethtool interface, so it hasn't 
actually made it into a released kernel at this point.

It seems reasonable for 2.6.34 to either add ETHTOOL_GSTRINGS_COUNT or 
update drvinfo.  Even if net-next has already been pulled into 
post-2.6.33 merge window, that would IMO qualify as a reasonable 
interface bugfix to get upstream.  The ethtool n-tuple ABI is not locked 
into stone until 2.6.34 is released by Linus.

	Jeff


