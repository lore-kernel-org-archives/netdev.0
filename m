From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH net] bridge: allow receiption on disabled port
Date: Thu, 10 Oct 2013 22:56:33 +0200
Message-ID: <52571481.5010907@openwrt.org>
References: <1381409570-1892-1-git-send-email-nbd@openwrt.org> <20131010133646.1bdd42c1@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:49530 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757329Ab3JJU4g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Oct 2013 16:56:36 -0400
In-Reply-To: <20131010133646.1bdd42c1@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-10-10 10:36 PM, Stephen Hemminger wrote:
> On Thu, 10 Oct 2013 14:52:50 +0200
> Felix Fietkau <nbd@openwrt.org> wrote:
> 
>> When an ethernet device is enslaved to a bridge, and the bridge STP
>> detects loss of carrier (or operational state down), then normally
>> packet receiption is blocked.
>> 
>> This breaks control applications like WPA which maybe expecting to
>> receive packets to negotiate to bring link up. The bridge needs to
>> block forwarding packets from these disabled ports, but there is no
>> hard requirement to not allow local packet delivery.
>> 
>> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
>> Signed-off-by: Felix Fietkau <nbd@openwrt.org>
> 
> No. This will cause duplicate packets to be delivered.
How? I haven't observed any duplications in my tests with this patch.

> If doing a link layer protocol like WPA then it should be done directly
> on the underlying device, not the bridge itself.
When the ETH_P_PAE protocol is set for the packet socket inside
wpa_supplicant, the bridge steals all packets before the protocol
handler gets them.
In __netif_receive_skb_core, only ptype_all gets processed before the rx
handler, not ptype_base.


- Felix
