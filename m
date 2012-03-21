From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: locking in net_device_ops callbacks
Date: Wed, 21 Mar 2012 12:25:03 -0700
Message-ID: <20120321122503.25838566@nehalam.linuxnetplumber.net>
References: <471DE477E2B1F549A58F3A14A27180BE014357@HQ-EX01.bytemobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jeff Haran <jharan@bytemobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33372 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752106Ab2CUTZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2012 15:25:08 -0400
In-Reply-To: <471DE477E2B1F549A58F3A14A27180BE014357@HQ-EX01.bytemobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Mar 2012 18:59:30 +0000
Jeff Haran <jharan@bytemobile.com> wrote:

> Hi,
> 
> I had posted the below to the kernelnewbies email list and never got a response. I am hoping somebody on this list could provide some feedback.
> 
> Just to be clear, it's not the issue of copying the MAC address that I am asking about. That's just an example.
> 
> What I am trying to understand is, what mechanisms generally are at play to serialize access to struct net_device private data that is accessed in both process and softirq contexts? Explicit locking "seems" to be mostly absent from the driver sources I've inspected so I can't help but believe I am missing something fundamental here.

Look at rtnl_lock() in net/core/rtnetlink.c; this is global mutex against
all changes to network device state.
