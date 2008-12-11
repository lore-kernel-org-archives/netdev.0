From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netpoll: fix race on poll_list resulting in garbage
 entry
Date: Thu, 11 Dec 2008 09:01:04 -0800
Message-ID: <20081211090104.02cab3d4@s6510>
References: <20081209210644.GC3785@hmsreliant.think-freely.org>
	<20081211130728.GB5910@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52096 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756654AbYLKRBL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2008 12:01:11 -0500
In-Reply-To: <20081211130728.GB5910@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Dec 2008 13:07:28 +0000
Jarek Poplawski <jarkao2@gmail.com> wrote:

> On 09-12-2008 22:06, Neil Horman wrote:
> ...
> > When executing napi->poll from the netpoll_path, this bit will
> > be set. When a driver calls netif_rx_complete, if that bit is set, it will not
> > remove the napi_struct from the poll_list.  That work will be saved for the next
> > iteration of net_rx_action.
> 
> This could be not enough: some drivers, e.g. sky2, call napi_complete()
> directly.
> 

There is good reason for this. Although most drivers only have one NAPI
instance per device, and multiqueue drivers have several NAPI structures
per device, a few devices like sky2 need to support multiple devices
running off one NAPI receive. The Marvell hardware has a common receive
interrupt for both ports on a dual port card.

This kind of hardware limits usage of netpoll. Only one port can be
used with netpoll because netpoll makes assumptions about NAPI
association.
