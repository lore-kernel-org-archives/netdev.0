From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: IP over 802.2 with LLC/SNAP
Date: Wed, 27 Jul 2011 13:32:09 +0100
Message-ID: <20110727133209.0d9dd6c4@lxorguk.ukuu.org.uk>
References: <4E2F8B7B.80906@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: Alan Ott <alan@signal11.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:38536 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751142Ab1G0M3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2011 08:29:09 -0400
In-Reply-To: <4E2F8B7B.80906@signal11.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> So the question is, does Linux support IP over 802.2 with LLC/SNAP? Is 
> there a sysfs/proc entry that I have to turn on to make this work (I 
> didn't find one)? I have the LLC2 module loaded, and I believe my packet 
> to be correct, since Windows recognizes it and since Wireshark doesn't 
> give any red flags on it. I've been unable to find anything about this 
> kind of thing in my searching.

Linux supports LLC/SNAP and various things over it (IPX/Appletalk DDP
etc) but not IP over it, as it's one of those standards bodies driven
bogosities which nobody ever actually deployed.

You are about the first person in the known universe to care 8). Now
there isn't any reason for not supporting it. The receive side is a case
of using register_snap_client() and piping the frames into the IP stack.

The send side could be tackled two ways I can see, one would be to allow
for snap protocols to be set somehow on devices and routes, the other
that might be simply would be to create a 'snapifier' device that added
snap headers then routed the frame via the bound physical device as
802.2 LLC. That way you'd be able to do

	route add gould-relic dev snap0

In both cases you'd need to tackle ARP but that seems to need no
configuration as SNAP requests get SNAP replies, and so on.

It should be a 'simple matter of hacking' and there are example devices
that fiddle with packets and add headers etc you can nick a lot of code
from. I figure if you can write an IP stack for an ancient Gould system
you can probably do that.

The other way is to use the Linux raw packet interfaces, open a raw
socket, push a BPF filter onto it to just get the frames for IP/SNAP and
ARP/SNAP then modify them and feed them to the kernel tun/tap interface.

Alan
