From: Ben Greear <greearb@candelatech.com>
Subject: Re: Linux, tcpdump and vlan
Date: Fri, 20 Jul 2007 13:34:28 -0700
Message-ID: <46A11C54.2090100@candelatech.com>
References: <997818.30021.qm@web56615.mail.re3.yahoo.com> <m31wf226fw.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: andrei radulescu-banu <iubica2@yahoo.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:38028 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757349AbXGTUfK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jul 2007 16:35:10 -0400
In-Reply-To: <m31wf226fw.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krzysztof Halasa wrote:
> Another idea - perhaps we could make the software VLANs behave
> the same as hw ones? I.e., stripping the tag on RX while setting
> some magic skb field?
> 
> The packets could go via main interface first (normal path, with
> eth_type_trans stripping the tag and setting protocol = some 802.1Q),
> netif_rx | netif_receive_skb, then through the VLAN device with
> finally eth_type_trans setting the IPv4 etc. protocol to pass to
> L3 layers.

There is already a flag you can set on vlan devices (reorder-header)
that strips the VLAN tag before presenting it to user-space.

> I can see potential problems on TX, the packets would have to be
> presented without the tag (but with VLAN ID set somewhere in the skb)
> and that probably means all drivers would have to be modified.

On tx, if it shows up on the vlan device, we add that device's VID to
the header if no VID is currently in the SKB.  If it is in the SKB header
we change the VID to be the tx dev's VID (if it was different).  This allows user-space
to send a raw ethernet frame on a vlan device and have it automatically
go out of the box on the correct vlan.  User-space can also send raw VLAN frames
and have those also go out on the correct VLAN.

> Seems a bit of work, I know my message is missing the patch...

Unless I mis-understand, this has been working since 2.4 days :)

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

