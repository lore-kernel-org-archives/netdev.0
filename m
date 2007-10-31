From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: expected behavior of PF_PACKET on NETIF_F_HW_VLAN_RX device?
Date: Wed, 31 Oct 2007 12:33:59 -0700
Message-ID: <20071031123359.3954befc@freepuppy.rosehill>
References: <18216.52455.698606.497464@zeus.sw.starentnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Bin Guo <bguo@sw.starentnetworks.com>
To: Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752636AbXJaTfM@vger.kernel.org>
In-Reply-To: <18216.52455.698606.497464@zeus.sw.starentnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 31 Oct 2007 14:43:51 -0400
Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com> wrote:

> 
> Depending on the network driver, I'm seeing different behavior if
> a .1q packet is received to an PF_PACKET, SOCK_RAW, ETH_P_ALL socket.
> 
> 
> On devices what do not use NETIF_F_HW_VLAN_RX, the packet socket gets
> the complete packet with vlan tag included as the driver simply calls
> netif_receive_skb() or equivilant.  packet_rcv() then gets the whole
> thing vlan tag included and sends this through the socket.
> 
> vlan_skb_recv() also gets these all and will drop them because there
> are no vlans configured.
> 

The VLAN acceleration grabs and hides the tag. It is a design flaw
that should be fixed, feel free to post a patch.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
