From: Ben Greear <greearb@candelatech.com>
Subject: Re: Strange igb bug, out-of-tree driver seems to work fine.
Date: Tue, 26 Apr 2011 21:18:08 -0700
Message-ID: <4DB79900.4030209@candelatech.com>
References: <4DB0A3FF.8080203@candelatech.com> <EDC0E76513226749BFBC9C3FB031318F01382E2CEF@orsmsx508.amr.corp.intel.com> <4DB0F965.4080605@candelatech.com> <EDC0E76513226749BFBC9C3FB031318F016B41256F@orsmsx508.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51679 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779Ab1D0ESK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 00:18:10 -0400
In-Reply-To: <EDC0E76513226749BFBC9C3FB031318F016B41256F@orsmsx508.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/26/2011 04:23 PM, Wyborny, Carolyn wrote:

> Hello,
>
> I'm sorry for the delay in responding.  I'm really scratching my head on this one as we don't do much in the driver that affects what we get on receive.  I've seen situations where some switches end up transmitting more of these and then we record more of them, but I'm guessing you're testing with the same equipment, just a different driver version.  Let me know if I'm mistaken there.
>
> So, to answer your question, I believe my patches are there, but I did review them again and I'm not sure they will make any difference.  My latest batch of patches was to add features to the i350 device specifically.
>
> Give it try though and let me know if you see any difference with 2.6.39-rc4+.

We reproduced this with stock 2.6.38.4 today, but I didn't get a chance to really
dig into it.

We only seem to have problems when the nics are associated with a kernel bridge
(some ports are connected to a pair of veth devices through a user-space bridge
that uses packet sockets to bridge the packets, and one of the veth interfaces
is in the kernel bridge).

We did run the same igb system to itself sending layer-3 traffic and it ran
fine, so it appears to be a fairly tricky bug.  It *almost* looks like issues
with the bridge or how we set things up, but we can reliably reproduce it
on in-kernel igb driver systems, and e1000e systems never see the problem.

I'll try to get some better debug info tomorrow, and if time allows,
we'll try on the stock linus top-of-tree kernel as well.  If top-of-tree
does work, I should be able to bisect the problem since we have a reliable
test case..would be interesting to see where the issues lies.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
