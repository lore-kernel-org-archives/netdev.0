From: Ben Greear <greearb@candelatech.com>
Subject: Re: Question on e1000 patch, rx-copy-break related.
Date: Thu, 04 May 2006 09:48:15 -0700
Message-ID: <445A304F.9040504@candelatech.com>
References: <4457B96A.4030808@candelatech.com>	 <4807377b0605031022s3b5bfad2x757fbd470884c6fd@mail.gmail.com>	 <4458F2A2.60605@candelatech.com> <4807377b0605040900y31bfaec3o73cb04c5c9a2e4e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:57750 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1030223AbWEDQsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 May 2006 12:48:24 -0400
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
In-Reply-To: <4807377b0605040900y31bfaec3o73cb04c5c9a2e4e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Brandeburg wrote:

>> My personal preference is to set a flag in the skb struct indicating 
>> whether
>> or not the crc is appended (and skb_put).  Then, bridging code can 
>> ignore it if needed,
>> and sniffers and such can get the CRC in user-land.  To remain 
>> backwards compat,
>> at least the skb-put of the crc logic should default to OFF so that we 
>> don't
>> break any existing user-land bridging logic.  I have the ethtool API 
>> logic written to
>> twiddle this save-crc behaviour if someone decides this is worthy of 
>> the kernel.
> 
> 
> that seems like an excellent idea, however, finding room in the skb
> struct is fun.

This field has 2 bits free.  We only need one bit for this feature.

	__u8			pkt_type:3,
				fclone:2,
				ipvs_property:1;

>> > Well, its a changing picture.  I had planned to eventually enable the
>> > hardware to strip the CRC if we aren't connected to some kind of
>> > offboard management.  We'll get there in steps.
>>
>> So, as of 2.6.16.13, is the hardware stripping (SERC) enabled?  Could
>> you also let me know where this bit is defined in case I want to twiddle
>> it myself (a quick grep for SERC in 2.6.16.13 yields nothing.)
> 
> 
> Yes, SECRC is enabled in 2.6.16, for both packet split and legacy
> receive paths.  It will probably stay enabled for 2.6.17 too unless
> the BMC communication bug is rated important enough for the change to
> be made.  Unfortunately right now due to SECRC bit being set BMC
> communication over SMBUS is likely broken.

Ok, thanks for the info.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

