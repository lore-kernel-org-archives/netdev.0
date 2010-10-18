From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Bridge] EAPOL bridging
Date: Mon, 18 Oct 2010 09:38:37 -0700
Message-ID: <20101018093837.26bb149a@nehalam>
References: <4CBB3B24.2000106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Benjamin Poirier <benjamin.poirier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:34926 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755406Ab0JRQja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 12:39:30 -0400
In-Reply-To: <4CBB3B24.2000106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 17 Oct 2010 14:06:28 -0400
Benjamin Poirier <benjamin.poirier@gmail.com> wrote:

> Hello,
> 
> I have some trouble bridging EAPOL frames. I'd like to do this to allow 
> wired 802.1x authentication from within a kvm virtual machine. I have 
> the following setup:
> 
> kvm -- tap0 -- br0 -- eth1 -- 802.1x authenticator (switch) -- more network
> 
> and it doesn't work. I've added a few logging rules to ebtables. I only 
> see an EAPOL frame going through the INPUT chain of tap0. It seems to be 
> dropped by the bridge. The EAPOL frame is an ethernet link local 
> multicast frame with destination address 01-80-C2-00-00-03, "IEEE Std 
> 802.1X PAE address".
> 
> I've looked at http://standards.ieee.org/regauth/groupmac/tutorial.html, 
> which says that frames with a destination in the range 01-80-C2-00-00-00 
> to 01-80-C2-00-00-0F should not be forwarded by standard conformant 
> bridges. I've also looked at net/bridge/br_input.c and br_handle_frame() 
> seems quite intent on "bending" the standard when STP is disabled, but 
> only for 01-80-C2-00-00-00. However there are more applications that use 
> similar addresses, EAPOL included: 
> http://standards.ieee.org/regauth/groupmac/Standard_Group_MAC_Address_assignments.pdf
> 
> Given the current state of affairs, would it be acceptable to make the 
> code more permissive by forwarding all the range of reserved group 
> addresses when STP is disabled? If not, what would be the way to go 
> about enabling 802.1x authentication from within a virtual machine?
> 
> BTW, it seems this issue has been raised before, 
> https://lists.linux-foundation.org/pipermail/bridge/2007-November/005629.html
> with the conclusion that
> > Despite what the standards say, many users are using bridging code for invisible
> > firewalls etc, and in those cases they want STP and EAPOL frames to be forwarded.

I would just take off the last byte (dest check).



-- 
