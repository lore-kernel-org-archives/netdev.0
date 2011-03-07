From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [ethtool PATCH 2/2] Add RX packet classification interface
Date: Mon, 07 Mar 2011 10:43:51 -0800
Message-ID: <4D752767.9060205@intel.com>
References: <20110211010806.23554.98333.stgit@gitlad.jf.intel.com>	 <20110211011838.23554.3735.stgit@gitlad.jf.intel.com>	 <1298302841.2608.35.camel@bwh-desktop>  <4D642222.6050202@intel.com>	 <1298939712.2569.43.camel@bwh-desktop>  <4D7138EF.7050606@intel.com>	 <1299513430.2522.9.camel@bwh-desktop>  <4D751038.9040804@intel.com>	 <1299520664.2522.21.camel@bwh-desktop>  <4D75225B.3010008@chelsio.com> <1299522481.2522.24.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Dimitris Michailidis <dm@chelsio.com>,
	Santwona Behera <santwona.behera@sun.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:22936 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752565Ab1CGSn5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 13:43:57 -0500
In-Reply-To: <1299522481.2522.24.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/7/2011 10:28 AM, Ben Hutchings wrote:
> On Mon, 2011-03-07 at 10:22 -0800, Dimitris Michailidis wrote:
>> Ben Hutchings wrote:
>>> On Mon, 2011-03-07 at 09:04 -0800, Alexander Duyck wrote:
>>>> The only time where location really matters is if you are attempting to
>>>> overwrite an existing rule and I am not sure how that would be handled
>>>> in ntuple anyway since right now adding additional rules via ntuple for
>>>> ixgbe just results in duplicate rules being defined.
>>>
>>> As I understand it, the location also determines the *priority* for the
>>> rule.
>>
>> This is true, at least for TCAMs.  But it's relevant only when multiple
>> filters would match a packet.  People often use non-overlapping filters, for
>> these adding the filter at any available slot is OK.
>
> Right.  But ethtool would have to determine that the filter was non-
> overlapping, before ignoring the location.  Also it cannot allow
> deletion by location if it ever ignores the location on insertion.  We
> should make the location optional at both the command-line and API
> level, but never ignore it.
>

I wasn't implying that we ignore it for rules inserted via the nfc 
interface.  Only for those inserted via the ntuple interface.

My reasoning for that was because it had occurred to me that what my 
patch series had done is allow for ntuples to be displayed via the 
get_rx_nfc interface.  As such you would end up with a location being 
implied when displaying the rules since it would give you a list of n 
entities.

If you attempted to restore the rules you would probably end up with the 
location information for filters 0..(n-1), and that could be dropped 
since it would just be extra information.

>>> Which is why I wrote that "@fs.@location specifies the index to
>>> use and must not be ignored."
>>>
>>> To support hardware where the filter table is hash-based rather than a
>>> TCAM, we would need some kind of flag or special value of location that
>>> means 'wherever'.
>>
>> I'd find the 'wherever' option useful for TCAMs too.  Maybe even have a few
>> of those, like 'first available', 'any', and 'last available'.  The last one
>> is quite useful for catch-all rules without requiring one to know the TCAM size.
>
> Agreed.
>
> Ben.

The first and last options make a lot of sense to me.  The one I'm not 
sure about would be the "any" option.  It seems like it would be 
redundant with the "first available" option or is there something I'm 
missing?

Also the code I have currently for the user space is just starting at 0 
and filling in the rules on a first available basis for location not 
specified.  Is this going to work for most cases or should I look at 
changing it to something like a "last available" approach for the nfc 
based filters?

Thanks,

Alex

