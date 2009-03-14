From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] bonding: allow bond in mode balance-alb to work
 properly in bridge
Date: Fri, 13 Mar 2009 22:39:32 -0700
Message-ID: <20090313223932.50ebbd88@nehalam>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, davem@davemloft.net,
	bridge@lists.linux-foundation.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:47820 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750876AbZCNFlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 01:41:22 -0400
In-Reply-To: <20090313183303.GF3436@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Mar 2009 19:33:04 +0100
Jiri Pirko <jpirko@redhat.com> wrote:

> Hi all.
> 
> This is only a draft of patch to consult. I'm aware that it should be divided
> into multiple patches. I want to know opinion from you folks.
> 
> The problem is described in following bugzilla:
> https://bugzilla.redhat.com/show_bug.cgi?id=487763
> 
> Basically here's what's going on. In every mode, bonding interface uses the same
> mac address for all enslaved devices. Except for mode balance-alb. When you put
> this kind of bond device into a bridge it will only add one of mac adresses into
> a hash list of mac addresses, say X. This mac address is marked as local. But
> this bonding interface also has mac address Y. Now then packet arrives with
> destination address Y, this address is not marked as local and the packed looks
> like it needs to be forwarded. This packet is then lost which is wrong.
> 
> Notice that interfaces can be added and removed from bond while it is in bridge.
> Therefore I introduce another function pointer in struct net_device_ops -
> ndo_check_mac_address. This function when it's implemented should check passed
> mac address against the one set in device. I'm using this in bonding driver when
> the bond is in mode balance-alb to walk thru all slaves and checking if any of
> them equals passed address.
> 
> Then in bridge function br_handle_frame_finish() I'm using ndo_check_mac_address
> to recognize the destination mac address as local.
> 
> Please look at this and tell me what you think about it.
> 
> Thanks
> 
> Jirka
>

A better and more general way to do this have the dev_set_mac_address
function check the return of the notifier and unwind. Then any protocol
can easily prevent address from changing.
