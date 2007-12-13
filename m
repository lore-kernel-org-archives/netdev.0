From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] net: napi fix
Date: Thu, 13 Dec 2007 14:49:53 +0100
Message-ID: <20071213134953.GA3806@ff.dom.local>
References: <47602B77.2090202@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, gallatin@myri.com,
	joonwpark81@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	shemminger@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:26398 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753861AbXLMNow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 08:44:52 -0500
Received: by nf-out-0910.google.com with SMTP id g13so562625nfb.21
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 05:44:50 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47602B77.2090202@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-12-2007 19:41, Kok, Auke wrote:
> David Miller wrote:
>> From: Andrew Gallatin <gallatin@myri.com>
>> Date: Wed, 12 Dec 2007 12:29:23 -0500
>>
>>> Is the netif_running() check even required?
>> No, it is not.
>>
>> When a device is brought down, one of the first things
>> that happens is that we wait for all pending NAPI polls
>> to complete, then block any new polls from starting.
> 
> I think this was previously (pre-2.6.24) not the case, which is why e1000 et al
> has this check as well and that's exactly what is causing most of the
> net_rx_action oopses in the first place. Without the netif_running() check
> previously the drivers were just unusable with NAPI and prone to many races with
> down (i.e. touching some ethtool ioctl which wants to do a reset while routing
> small packets at high numbers). that's why we added the netif_running() check in
> the first place :)
> 
> There might be more drivers lurking that need this change...
> 

As a matter of fact, since it's "unlikely()" in net_rx_action() anyway,
I wonder what is the main reason or gain of leaving such a tricky
exception, instead of letting drivers to always decide which is the
best moment for napi_complete()? (Or maybe even, in such a case, they
should call some function with this list_move_tail() if it's so
useful?)

Regards,
Jarek P.
