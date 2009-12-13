From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC: ethtool: add device-specific feature support in a generic
 fashion
Date: Sat, 12 Dec 2009 20:19:18 -0800
Message-ID: <4B246B46.1010103@candelatech.com>
References: <1260671599.2142.79.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>, mchan@broadcom.com,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	linville@tuxdriver.com, shemminger@linux-foundation.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53205 "HELO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750732AbZLMETg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2009 23:19:36 -0500
In-Reply-To: <1260671599.2142.79.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/12/2009 06:33 PM, Peter P Waskiewicz Jr wrote:
> This is a follow-up to my first RFC, getting opinions where the best
> place to put device-specific feature toggling would be.  The feedback I
> received was to look at doing this in ethtool.  Below is a high-level
> design of what I'd like to do, and wanted to vet this with the community
> to see if this is aligned with what people would like to see.
>
> The general idea is to have a generic framework in ethtool to enumerate
> device-specific commands.  A sample structure that would represent each
> of these commands is:
>
> 	enum oem_cmds {
> 		OEM_CMD_0 = 0,
> 		OEM_CMD_1,
> 		OEM_CMD_2,
> 	...
> 	etc.
> 	...
> 	};
>
> 	struct oem_feature_cmd {
> 		/* Description of the feature */
> 		char *description;
>
> 		/* Does the feature toggling requires a device reset */
> 		u8 require_reset;
>
> 		/* The command-line name for the command */
> 		char *oem_cmd_name;
>
> 		/* The command number assigned to this */
> 		u32 oem_cmd;
>
> 		/* value for the command */
> 		u32 oem_cmd_val;
> 	};

I'd add a 32-bit field for flags, with require_reset being one of them.  I'd also
align it so that it has no holes on 32/64 bit (put char*'s next to each other, maybe
pad with another 32-bit 'spare' field.  Maybe even use uint64 for the pointers so
that the struct size is same on 32-bit and 64-bit, to aid using 32-bit apps on
64-bit OS easily.

This way, as new uses are found for this, the structure remains binary compatible.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
