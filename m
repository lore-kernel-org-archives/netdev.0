From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [RFC] net: napi fix
Date: Thu, 13 Dec 2007 09:13:54 -0500
Message-ID: <47613E22.6060705@myri.com>
References: <47601A73.5010804@myri.com>	 <20071212.093819.205755031.davem@davemloft.net>	 <47602B77.2090202@intel.com> <b25c3fa70712122341q3ba282cdqda3fa56901b14484@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	shemminger@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1955 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754768AbXLMOTp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 09:19:45 -0500
In-Reply-To: <b25c3fa70712122341q3ba282cdqda3fa56901b14484@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joonwoo Park wrote:
 > 2007/12/13, Kok, Auke <auke-jan.h.kok@intel.com>:
 >> David Miller wrote:
 >>> From: Andrew Gallatin <gallatin@myri.com>
 >>> Date: Wed, 12 Dec 2007 12:29:23 -0500
 >>>
 >>>> Is the netif_running() check even required?
 >>> No, it is not.
 >>>
 >>> When a device is brought down, one of the first things
 >>> that happens is that we wait for all pending NAPI polls
 >>> to complete, then block any new polls from starting.
 >> I think this was previously (pre-2.6.24) not the case, which is why 
e1000 et al
 >> has this check as well and that's exactly what is causing most of the
 >> net_rx_action oopses in the first place. Without the netif_running() 
check
 >> previously the drivers were just unusable with NAPI and prone to 
many races with
 >> down (i.e. touching some ethtool ioctl which wants to do a reset 
while routing
 >> small packets at high numbers). that's why we added the 
netif_running() check in
 >> the first place :)
 >>
 >> There might be more drivers lurking that need this change...
 >>
 >> Auke
 >>
 >
 > Also in my case, without netif_running() check, I cannot do ifconfig 
down.
 > It stucked if packet generator was sending packets.

If the netif_running() check is indeed required to make a device break
out of napi polling and respond to an ifconfig down, then I think the
netif_running() check should be moved up into net_rx_action() to avoid
potential for driver complexity and bugs like the ones you found.

Drew
