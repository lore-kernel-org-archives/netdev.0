From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-next 1/8] i40e: main driver core
Date: Thu, 20 Jun 2013 13:52:39 -0700
Message-ID: <51C36B97.6000000@intel.com>
References: <1371182122-26629-1-git-send-email-jeffrey.t.kirsher@intel.com>  <1371182122-26629-2-git-send-email-jeffrey.t.kirsher@intel.com>  <1371665562.1956.89.camel@bwh-desktop.uk.level5networks.com>  <FC41C24E35F18A40888AACA1A36F3E4168533EA6@FMSMSX102.amr.corp.intel.com> <1371758085.1946.12.camel@bwh-desktop.uk.level5networks.com> <FC41C24E35F18A40888AACA1A36F3E4168533F1F@FMSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Nelson, Shannon" <shannon.nelson@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:18485 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161253Ab3FTUws (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 16:52:48 -0400
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E4168533F1F@FMSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/20/2013 01:01 PM, Nelson, Shannon wrote:
>> From: Ben Hutchings [mailto:bhutchings@solarflare.com]
>> Sent: Thursday, June 20, 2013 12:55 PM
>>
>> On Thu, 2013-06-20 at 19:46 +0000, Nelson, Shannon wrote:
>>>> From: Ben Hutchings [mailto:bhutchings@solarflare.com]
>>>> Sent: Wednesday, June 19, 2013 11:13 AM
>>>>
>>>> On Thu, 2013-06-13 at 20:55 -0700, Jeff Kirsher wrote:
>>>>> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> [...]
>>>> You should be using rtnl_device_stats64; at 40G a 32-bit counter is
>>>> ridiculous (using this in a 32-bit machine is a bit ridiculous too,
>>>> though...)
>>> You mean rtnl_link_stats64?  Sure.
>> Right, yes.
>>
>>> Yes, this driver is really not meant for a 32-bit machine.  We've
>>> discussed making sure it would only build for 64-bit, but hadn't quite
>>> gotten around to implementing the restriction.  It seems the right
>>> thing to do - would anyone in the community get bent out of shape if
>>> we added that?
>> I'm afraid they probably would.
> Yeah, that was our thought.  We're going to try to make sure it at least compiles cleanly, but I'm not sure we'll be able to guarantee useful performance.
>
>> [...]
>>>>> +/**
>>>>> + * i40e_config_rss - Prepare for RSS if used
>>>>> + * @pf: board private structure
>>>>> + **/
>>>>> +static s32 i40e_config_rss(struct i40e_pf *pf)
>>>>> +{
>>>>> +	struct i40e_hw *hw = &pf->hw;
>>>>> +	u32 lut = 0;
>>>>> +	int i, j;
>>>>> +	u64 hena;
>>>>> +	/* Set of random keys generated using kernel random number
>>>> generator */
>>>>> +	static const u32 seed[I40E_PFQF_HKEY_MAX_INDEX + 1] =
>> {0x41b01687,
>>>>> +				0x183cfd8c, 0xce880440, 0x580cbc3c,
>> 0x35897377,
>>>>> +				0x328b25e1, 0x4fa98922, 0xb7d90c14,
>> 0xd5bad70d,
>>>>> +				0xcd15a2c1, 0xe8580225, 0x4a1e9d11,
>> 0xfe5731be};
>>>> Chosen by a fair dice roll?
>>> Well, as fair as /dev/random gets.
>> [...]
>>
>> My point is: once you turn a random choice into a constant, it's no
>> longer random.
Without a pool of statically-allocated random bytes for the seeds, RSS 
determinism is impossible.  From test to test, workloads would be 
completely different, unless your test harness always used the same 
source and destination ports, which is not aligned with reality.

-PJ

> Point taken, but we just wanted a random set of bits to start, just as we did in ixgbe.
>
> Thanks,
> sln
>
