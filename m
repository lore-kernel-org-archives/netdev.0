From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [patch net-next] cxgb3: update firmware version
Date: Mon, 13 Feb 2012 21:55:41 -0800
Message-ID: <4F39F75D.6030107@chelsio.com>
References: <20120213202846.631.30806.stgit@speedy5.asicdesigners.com> <1329165817.2092.62.camel@shinybook.infradead.org> <4F398303.1030606@chelsio.com> <1329184754.3048.33.camel@deadeye> <4F39E7C9.20901@chelsio.com> <1329196116.3048.66.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Woodhouse <dwmw2@infradead.org>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>, nhorman@tuxdriver.com
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:44590
	"EHLO l.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752458Ab2BNF4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 00:56:25 -0500
In-Reply-To: <1329196116.3048.66.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/13/2012 9:08 PM, Ben Hutchings wrote:
> On Mon, 2012-02-13 at 20:49 -0800, Divy Le Ray wrote:
>> On Monday, February 13, 2012 5:59:14 PM, Ben Hutchings wrote:
>>> On Mon, 2012-02-13 at 13:39 -0800, Divy Le Ray wrote:
>>>> On Monday, February 13, 2012 12:43:37 PM, David Woodhouse wrote:
>>>>>
>>>>> On Mon, 2012-02-13 at 12:28 -0800, Divy Le Ray wrote:
>>>>>>
>>>>>> This patch updates the firmware version cxgb3 is requesting to 7.12.0.
>>>>>
>>>>>
>>>>> I'm confused. Your patch doesn't change anything in the driver, except
>>>>> the firmware version. So why is it a "major" change?
>>>>
>>>> Hi David,
>>>>
>>>> cxgb3 embeds the firmware file name it will request at load time.
>>>> It uses the FW_VERSION_* defs to construct the firmware name FW_FNAME
>>>> before calling request_firmware().
>>>> Hence the need to update the firmware minor version.
>>>>
>>>> On the other hand, the driver version update is not a strict requirement
>>>> here.
>>>> I would prefer keeping it though.
>>>
>>> The problems with this are:
>>> 1. Older kernel versions don't benefit from the firmware update.
>>> 2. The old firmware has to be kept in linux-firmware to support those
>>> old kernel versions, and distributions may have to package more
>>> versions.
>>>
>>> To avoid this, the firmware filename should only be changed if you make
>>> incompatible changes in the driver/firmware interface.
>> Hi Ben,
>>
>> The scheme for cxgb3 firmware update was designed in coordination with
>> OEMs in the early stages of the driver existence back in 2007.
> I'm aware that some OEMs have specifications for flash firmware updates
> and version numbers.  I don't recall seeing anything about naming
> firmware files that are loaded by the driver at boot.
>
> In any case, whatever your OEMs want in out-of-tree driver packages is
> not necessarily relevant to mainline Linux.

Ben, it was about the driver committed to mainline linux.

>> Committing FW 7.12.0 under the name of t3fw-7.10.0.bin would be
>> confusing, in my mind.
> Indeed it would, but I was speaking in general terms - that it would be
> preferable to use something like t3fw-<major>.bin.

Okay, I understand now. We'd have to discuss it with the original OEMS 
and distributions.
I'd rather stick to the current scheme for the time being and update it 
once we have agreement from all parties.

> I assume that the firmware blob has a version embedded in it, so that
> the driver would still be able to report the exact version through
> ethtool_ops::get_drvinfo.
>
>> Some distributions have explicitly requested the FW rev number to be
>> appended to the firmware file name.
> Did they really want the full version there or did they want you to
> distinguish incompatible versions?  Did they assume that the file would
> be installed by a package (so that the package carries a version number)
> or not?

Our orginal approach for cxgb4 was to commit its firmware under a 
constant name.
Following minor FW updates overwrite the existing firmware file, and it 
raised some negative feedback.
The cxgb3 scheme had not raised any concern until today, it seemed 
natural to get back to
a similar approach for cxgb4, at least partially.

Cheers,
Divy
