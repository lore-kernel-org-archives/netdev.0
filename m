From: Tejun Heo <htejun@gmail.com>
Subject: Re: [patch 0/5][RFC] Update network drivers to use devres
Date: Fri, 03 Aug 2007 20:33:04 +0900
Message-ID: <46B31270.7090503@gmail.com>
References: <20070802224206.GB5181@ifup.org>	<20070803095857.5fb3f368@oldman.hamilton.local>	<20070803102645.GO13674@htj.dyndns.org> <20070803120745.2d89c221@oldman.hamilton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Brandon Philips <brandon@ifup.org>, netdev@vger.kernel.org,
	teheo@suse.de
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.191]:5071 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758872AbXHCLdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Aug 2007 07:33:11 -0400
Received: by rv-out-0910.google.com with SMTP id k20so655243rvb
        for <netdev@vger.kernel.org>; Fri, 03 Aug 2007 04:33:11 -0700 (PDT)
In-Reply-To: <20070803120745.2d89c221@oldman.hamilton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Stephen Hemminger wrote:
>> Skimming through drivers... via-rhine doesn't disable PCI device on
>> init failure path but does so on removal.  sky2 doesn't free
>> consistent memory if sky2_init() fails.  acenic calls iounmap() with
>> NULL parameter which I'm not sure whether it's safe or not.  natsemi
>> doesn't disable PCI device on failure or removal.
> 
> Did you report these to the developers?

Just skimmed through.  I'm pretty sure Brandon will pick those up later.

>> Devres makes low level drivers simpler, easier to get right and
>> maintain.  Writing new drivers becomes easier too.  So, why not?
>>
>>> Network devices seem to work fine thanks, and the resource requirements
>>> are different. If ain't broke, don't fix it.
>> Care to enlighten me on how the resource requirments are different
>> from ATA drivers?
> 
> I was thinking of the hot remove (no mod ref counts) and lingering
> /sys open issues.  ATA drivers use ref counts.

I guess the hot removing is done by severing netdev from the actual
device, right?  I don't see how that affects usage of devres on network
drivers.  Am I missing something?

On a separate note, can you explain lingering /sys open issue to me a
bit?  With recent sysfs changes, sysfs nodes are disconnected
immediately on deletion.  Would that make any difference to netdevs?

> My take on devres is that it is similar to talloc() for device drivers.
> Not a bad idea in itself, but the real advantage of hierarchical allocation
> is that it makes exception handling easier if things are layered deeply.

Yeah, devres made layering easier in libata, especially SFF stuff.
Dunno how much of that is applicable to netdev but, with or without
layering, it'll be a nice cleanup and I don't see much negative side.
Conversion would take some work and bugs might be introduced in the
process as with any changes but the good thing about devres is that
you're very likely to get failure/release paths right if you get the
init path right, and if you get the init path wrong, it will stand out
like a sore thumb - easy to spot, easy to fix.

So, I think using devres on net drivers is a good idea, well, for that
matter, for any driver, but me being the devres writer, that isn't
really surprising, is it?

Thanks.

-- 
tejun
