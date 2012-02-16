From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] bnx2x: tx-switching module parameter
Date: Thu, 16 Feb 2012 09:49:36 -0800
Message-ID: <20120216094936.3449e6ef@nehalam.linuxnetplumber.net>
References: <1329401112-9542-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Ariel Elior" <ariele@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60114 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751354Ab2BPRtn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Feb 2012 12:49:43 -0500
In-Reply-To: <1329401112-9542-1-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Feb 2012 16:05:12 +0200
"Ariel Elior" <ariele@broadcom.com> wrote:

> In 57712 and 578xx the tx-switching module parameter allows the user to control
> whether outgoing traffic can be loopbacked into the device in case there is a
> relevant client for the data using the same device for rx.
> A classic example where this is necessary is for virtualization purposes, where
> one vm is transmitting data to another, while both use different pci functions of
> the same port of the same nic.
> 
> In case there is a promiscuous client in the rx (which wants to receive all
> data) or if the traffic is broadcast, traffic may be sent on both the loopback
> channel and the physical wire.
> 
> The reason tx-switching is controlled by a module parameter is twofold:
> 1. There is a certain performance penalty for tx-switching because:
>    a. every packet must be compared against the receiver clients.
>    b. duplicated traffic being loopbacked can consume a significant portion of
>    the overall bandwidth, depending on the scenario.
> 2. Tx-switching doesn't make much sense as a per function parameter, but should
> rather be controlled uniformly for the  entire device. The reason is that if one
> interface wants to be able to send data on the loopback it is not enough to
> enable tx-switching for that interface, as the target interface must also
> register its rx classification information where the transmitting interface can
> find it. One would still have to use the module parameter in each VM, though.
> 
> Signed-off-by: Ariel Elior <ariele@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Module parameters are the hardware vendors friend, but the system
integrators nightmare. Although you think your hardware is special
but it isn't some other vendor will have same idea, how is user and
distribution supposed to control it?
