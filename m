From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next 1/3] sunvnet: upgrade to VIO protocol
 version 1.6
Date: Sat, 13 Sep 2014 23:01:20 -0400 (EDT)
Message-ID: <20140913.230120.511140402106277600.davem@davemloft.net>
References: <54146A42.1050703@oracle.com>
	<20140913.161842.2265200935397549583.davem@davemloft.net>
	<5414FFDD.9050509@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.stevens@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40336 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752276AbaINDBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 23:01:23 -0400
In-Reply-To: <5414FFDD.9050509@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <david.stevens@oracle.com>
Date: Sat, 13 Sep 2014 22:39:25 -0400

> 
> 
> On 09/13/2014 04:18 PM, David Miller wrote:
>> From: David L Stevens <david.stevens@oracle.com>
> 
>> static inline bool vio_version_before(struct vio_driver_state *vio,
>> 				      u16 major, u16 minor)
>> {
>> 	u32 have = (u32)vio->major << 16 | vio->minor;
>> 	u32 want = (u32)major << 16 | minor;
>> 
>> 	return have < want;
>> }
>> static inline bool vio_version_after_eq(struct vio_driver_state *vio,
>> 					u16 major, u16 minor)
>> {
>> 	u32 have = (u32)vio->major << 16 | vio->minor;
>> 	u32 want = (u32)major << 16 | minor;
>> 
>> 	return have >= want;
>> }
>> 
>> Something like that.
> 
> Sure. I was thinking about something like:
> 
> #define VIO_VER(major, minor)	(((major)<<16)|(minor))
> 
> change the version struct to a 32-bit int, and do things like:
> 
> 	if (vio->ver > VIO_VER(1,6)) {
> 
> unless you have a preference. (?)

I hate wasting space in a structure just to avoid some harmless
casting in a helper function that is simply trying to optimize
a comparison.

That's why I suggested the inline helpers above, which arguments
are strongly typed.
