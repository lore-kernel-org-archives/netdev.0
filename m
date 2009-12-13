From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: RFC: ethtool: add device-specific feature support in a generic
 fashion
Date: Sat, 12 Dec 2009 23:09:24 -0800
Message-ID: <1260688164.2142.84.camel@localhost>
References: <1260671599.2142.79.camel@localhost>
	 <4B246B46.1010103@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"mchan@broadcom.com" <mchan@broadcom.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"shemminger@linux-foundation.org" <shemminger@linux-foundation.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:7190 "HELO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750852AbZLMHJZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2009 02:09:25 -0500
In-Reply-To: <4B246B46.1010103@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-12-12 at 20:19 -0800, Ben Greear wrote:
> On 12/12/2009 06:33 PM, Peter P Waskiewicz Jr wrote:
> > This is a follow-up to my first RFC, getting opinions where the best
> > place to put device-specific feature toggling would be.  The feedback I
> > received was to look at doing this in ethtool.  Below is a high-level
> > design of what I'd like to do, and wanted to vet this with the community
> > to see if this is aligned with what people would like to see.
> >
> > The general idea is to have a generic framework in ethtool to enumerate
> > device-specific commands.  A sample structure that would represent each
> > of these commands is:
> >
> > 	enum oem_cmds {
> > 		OEM_CMD_0 = 0,
> > 		OEM_CMD_1,
> > 		OEM_CMD_2,
> > 	...
> > 	etc.
> > 	...
> > 	};
> >
> > 	struct oem_feature_cmd {
> > 		/* Description of the feature */
> > 		char *description;
> >
> > 		/* Does the feature toggling requires a device reset */
> > 		u8 require_reset;
> >
> > 		/* The command-line name for the command */
> > 		char *oem_cmd_name;
> >
> > 		/* The command number assigned to this */
> > 		u32 oem_cmd;
> >
> > 		/* value for the command */
> > 		u32 oem_cmd_val;
> > 	};
> 
> I'd add a 32-bit field for flags, with require_reset being one of them.  I'd also
> align it so that it has no holes on 32/64 bit (put char*'s next to each other, maybe
> pad with another 32-bit 'spare' field.  Maybe even use uint64 for the pointers so
> that the struct size is same on 32-bit and 64-bit, to aid using 32-bit apps on
> 64-bit OS easily.
> 
> This way, as new uses are found for this, the structure remains binary compatible.
> 

Excellent points.  Thanks Ben!

-PJ

