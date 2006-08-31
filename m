From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 08/26] e1000: Deprecate mii-tool SIOCMIIREG ioctl
Date: Thu, 31 Aug 2006 14:17:10 -0700
Message-ID: <44F751D6.6040101@intel.com>
References: <36D9DB17C6DE9E40B059440DB8D95F528A67D0@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	netdev@vger.kernel.org, akpm@osdl.org,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:59003 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932451AbWHaVSb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 17:18:31 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F528A67D0@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brandeburg, Jesse wrote:
> Jeff Garzik wrote:
>> Kok, Auke wrote:
>>> Deprecate mii-tool SIOCMIIREG ioctl. This ioctl is broken in e1000
>>> and ethtool has this functionality in working order.
>>>
>>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>> This doesn't "deprecated" anything, it changes the ABI on a
>> user's machine by _removing_ ioctl handling code that used to be
>> there. 
>>
>> What's broken, and what is needed to fix?  Perhaps e1000
>> should instead be limited to 10/100 networks/speeds?
> 
> mii-tool is broken because it doesn't understand GMII phys.  We ended up
> having a mess of code trying to implement the shim layer to support the
> PHY write ioctls, among others.
> mii-tool always reports 100 Mbps link when you actually have 1Gbps link.
> Using mii-tool to set options didn't work very well to begin with, so
> rather than continue to dump time into a dead end, just remove the
> incomplete/non-working code and force the user to use ethtool if they
> want to do set operations. 
> 
> Mii-tool is already marked in its man page to be obsolete
> 
> <quote from RHEL4>
> NOTE
>        This program is obsolete. Valid  media  are  only  100baseT4,
> 100baseTx-FD,100baseTx-HD,  10baseT-FD  and
>        10baseT-HD ethernet cards. For replacement check eth-tool.
> </quote>
> 
> We intentionally left the read code in to not break any user space
> programs that are using that IOCTL to read link status etc.  With some
> recent improvements to ethtool, it has the exact same functionality as
> mii-tool.
> 
> While I appreciate the "don't break user space" position, in this case
> it never really worked right, and when it did work the user was just
> lucky because they probably weren't getting what they wanted.

I'm dropping this patch from our stack, it seems (irony) that we might have 
some use for this ioctl after all and we need to re-evaluate what to do with 
it. It doesn't hurt (much) to leave it in there for now.

Jeff, I'll repost a summary of the changes I made to the queue on our gitserver 
in a second.

Cheers,

Auke
