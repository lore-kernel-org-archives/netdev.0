From: Ben Greear <greearb@candelatech.com>
Subject: Re: Provide ability to change default netdev name?
Date: Fri, 16 Aug 2013 16:48:38 -0700
Message-ID: <520EBA56.4050301@candelatech.com>
References: <520EA43F.2010304@candelatech.com> <1376696468.11042.74.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51641 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753665Ab3HQAPB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 20:15:01 -0400
In-Reply-To: <1376696468.11042.74.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/16/2013 04:41 PM, Ben Hutchings wrote:
> On Fri, 2013-08-16 at 15:14 -0700, Ben Greear wrote:
>> The latest udev in Fedora 19 (and perhaps elsewhere) will no longer
>> implement rules that rename an interface from ethX to ethY.  Nor
>> wlanX or other 'kernel namespaces'.  The Fedora udev developers do not seem
>> interested in changing this back to the old behaviour, evidently they
>> had a hard time implementing it properly.
>
> There is an inherent problem that a new device can appear at any time
> under the exact name udev is trying to rename to.  I expect it is
> possible to do this properly but may be quite difficult to eliminate the
> possibility of deadlock.
>
> Still, if udev actively refuses to use the 'kernel namespaces' (rather
> than just being configured not to), that would be a bug.

I agree, but the Fedora udev developers do not.  I'm not sure
if other distros will follow or not.

>> This effectively makes it impossible to have network device names of ethX
>> consistent across reboots in systems with multiple NICs and/or drivers.
>>
>> One way to work around this would be allow the kernel to use a different
>> default netdev name (for instance, keth%d).  I'm thinking this would be
>> configured as a kernel command line argument.  Then, a small change to udev/systemd to
>> make the 'kernel namespaces' configurable by letting it understand this new kernel
>> command line argument should resolve the problem.
>>
>> Does this sound like something that could be accepted upstream?
>
> This sounds completely ridiculous.

Yeah, seems lame to hack around funky user-space, but
if udev folks will truly not fix this, then life is
going to suck for users wanting to use 'ethX' naming
schemes for their network devices.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
