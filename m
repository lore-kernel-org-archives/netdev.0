From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Subject: Re: [PATCHv3 net-next 1/3] sunvnet: upgrade to VIO protocol version 1.6
Date: Sat, 13 Sep 2014 20:43:09 -0700
Message-ID: <A19FCF2B-0808-4BD5-9AF6-3830312DAEFF@oracle.com>
References: <54146A42.1050703@oracle.com> <20140913.161842.2265200935397549583.davem@davemloft.net> <5414FFDD.9050509@oracle.com> <20140913.230120.511140402106277600.davem@davemloft.net>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david.stevens@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:31899 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752271AbaINDnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 23:43:13 -0400
In-Reply-To: <20140913.230120.511140402106277600.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sep 13, 2014, at 8:01 PM, David Miller <davem@davemloft.net> wrote:

> From: David L Stevens <david.stevens@oracle.com>
> Date: Sat, 13 Sep 2014 22:39:25 -0400
> 
>> 
>> 
>> On 09/13/2014 04:18 PM, David Miller wrote:
>>> From: David L Stevens <david.stevens@oracle.com>
>> 
>>> static inline bool vio_version_before(struct vio_driver_state *vio,
>>> 				      u16 major, u16 minor)
>>> {
>>> 	u32 have = (u32)vio->major << 16 | vio->minor;
>>> 	u32 want = (u32)major << 16 | minor;
>>> 
>>> 	return have < want;
>>> }
>>> static inline bool vio_version_after_eq(struct vio_driver_state *vio,
>>> 					u16 major, u16 minor)
>>> {
>>> 	u32 have = (u32)vio->major << 16 | vio->minor;
>>> 	u32 want = (u32)major << 16 | minor;
>>> 
>>> 	return have >= want;
>>> }
>>> 
>>> Something like that.
>> 
>> Sure. I was thinking about something like:
>> 
>> #define VIO_VER(major, minor)	(((major)<<16)|(minor))
>> 
>> change the version struct to a 32-bit int, and do things like:
>> 
>> 	if (vio->ver > VIO_VER(1,6)) {
>> 
>> unless you have a preference. (?)
> 
> I hate wasting space in a structure just to avoid some harmless
> casting in a helper function that is simply trying to optimize
> a comparison.
> 
> That's why I suggested the inline helpers above, which arguments
> are strongly typed.

IMO, it would be more readable if we introduce the helper functions
that check for a specific feature than a specific version number
and hide the version number detail inside that helper function. Otherwise,
it will be harder to follow each version number check and why it is
being done. 

-Raghuram

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
