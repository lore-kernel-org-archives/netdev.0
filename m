From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH net] bridge: allow receiption on disabled port
Date: Fri, 11 Oct 2013 00:08:25 +0200
Message-ID: <52572559.5020009@openwrt.org>
References: <1381409570-1892-1-git-send-email-nbd@openwrt.org> <20131010133646.1bdd42c1@nehalam.linuxnetplumber.net> <52571481.5010907@openwrt.org> <20131010145255.16cf7c09@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:52762 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751225Ab3JJWIa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Oct 2013 18:08:30 -0400
In-Reply-To: <20131010145255.16cf7c09@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-10-10 11:52 PM, Stephen Hemminger wrote:
> On Thu, 10 Oct 2013 22:56:33 +0200
> Felix Fietkau <nbd@openwrt.org> wrote:
> 
>> On 2013-10-10 10:36 PM, Stephen Hemminger wrote:
>> > On Thu, 10 Oct 2013 14:52:50 +0200
>> > Felix Fietkau <nbd@openwrt.org> wrote:
>> > 
>> >> When an ethernet device is enslaved to a bridge, and the bridge STP
>> >> detects loss of carrier (or operational state down), then normally
>> >> packet receiption is blocked.
>> >> 
>> >> This breaks control applications like WPA which maybe expecting to
>> >> receive packets to negotiate to bring link up. The bridge needs to
>> >> block forwarding packets from these disabled ports, but there is no
>> >> hard requirement to not allow local packet delivery.
>> >> 
>> >> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>> >> Signed-off-by: Felix Fietkau <nbd@openwrt.org>
>> > 
>> > No. This will cause duplicate packets to be delivered.
>> How? I haven't observed any duplications in my tests with this patch.
> 
> The purpose of DISABLED state is to break loops in the bridge tree.
> If packet is flooded by another bridge (Broadcast Unknown or Multicast)
> then it will go down both paths.
Ah, right.

>> > If doing a link layer protocol like WPA then it should be done directly
>> > on the underlying device, not the bridge itself.
>> When the ETH_P_PAE protocol is set for the packet socket inside
>> wpa_supplicant, the bridge steals all packets before the protocol
>> handler gets them.
>> In __netif_receive_skb_core, only ptype_all gets processed before the rx
>> handler, not ptype_base.
> 
> Thought it was using direct type all. Or at least the link local multicast
> address.
> 
> Can you revise it to only accept packets directed to link local multicast
> address or local address, and go through the local_finish handler.
The destination address in WPA EAPOL packets from the AP is set to the
MAC address of the client, which may not be the same as the one from the
bridge.

- Felix
