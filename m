From: Jeff Haran <jharan@bytemobile.com>
Subject: RE: locking in net_device_ops callbacks
Date: Wed, 21 Mar 2012 20:38:02 +0000
Message-ID: <471DE477E2B1F549A58F3A14A27180BE0147A6@HQ-EX01.bytemobile.com>
References: <471DE477E2B1F549A58F3A14A27180BE014357@HQ-EX01.bytemobile.com>
 <20120321122503.25838566@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ironport.bytemobile.com ([12.153.136.13]:7976 "EHLO
	ironport.bytemobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760502Ab2CUUiY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 16:38:24 -0400
In-Reply-To: <20120321122503.25838566@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> Sent: Wednesday, March 21, 2012 12:25 PM
> To: Jeff Haran
> Cc: netdev@vger.kernel.org
> Subject: Re: locking in net_device_ops callbacks
> 
> On Wed, 21 Mar 2012 18:59:30 +0000
> Jeff Haran <jharan@bytemobile.com> wrote:
> 
> > Hi,
> >
> > I had posted the below to the kernelnewbies email list and never got a
> response. I am hoping somebody on this list could provide some feedback.
> >
> > Just to be clear, it's not the issue of copying the MAC address that I am
> asking about. That's just an example.
> >
> > What I am trying to understand is, what mechanisms generally are at play
> to serialize access to struct net_device private data that is accessed in both
> process and softirq contexts? Explicit locking "seems" to be mostly absent
> from the driver sources I've inspected so I can't help but believe I am missing
> something fundamental here.
> 
> Look at rtnl_lock() in net/core/rtnetlink.c; this is global mutex against
> all changes to network device state.

Steve,

Thanks for the response.

rtnl_lock() does this:

void rtnl_lock(void)
{
        mutex_lock(&rtnl_mutex);
}

I can see where that would serialize process context access, but as I understand it much of the networking stack runs in soft IRQ context. Soft IRQs can't take mutexes, can they?

It seems to me that some other serialization mechanism should be in place to serialize soft IRQ context access to instances of struct net_device.

Jeff Haran
