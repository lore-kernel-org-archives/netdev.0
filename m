From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 1/2 v5] usbnet: allow status interrupt URB to always be active
Date: Thu, 11 Apr 2013 13:14:35 +0200
Message-ID: <28454387.MvMlbQoOly@linux-5eaq.site>
References: <20110727141246.GC29616@orbit.nwl.cc> <3010836.mDNO71IiS7@linux-5eaq.site> <CACVXFVNHoBNpyRztp1Bu_41=YnszqQ3jQDw4j87Zd2hZM3r-VA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Dan Williams <dcbw@redhat.com>,
	Elina Pasheva <epasheva@sierrawireless.com>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Rory Filer <rfiler@sierrawireless.com>,
	Phil Sutter <phil@nwl.cc>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out002.kontent.com ([81.88.40.216]:35853 "EHLO
	smtp-out002.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752127Ab3DKLNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 07:13:50 -0400
In-Reply-To: <CACVXFVNHoBNpyRztp1Bu_41=YnszqQ3jQDw4j87Zd2hZM3r-VA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 11 April 2013 18:03:09 Ming Lei wrote:
> On Thu, Apr 11, 2013 at 5:53 PM, Oliver Neukum <oliver@neukum.org> wrote:
> > On Thursday 11 April 2013 16:09:16 Ming Lei wrote:
> >>
> >> Could you explain why work queue need GFP_NOIO?
> >
> > Your fix for the memory allocation depends on it happening in the same
> > context. If you execute code on a work queue this happens in the context
> > of a kernel thread.
> 
> I understand the interface might be called from workqueue, and my question
> is why GFP_NOIO is needed in the work queue context. Generally speaking,
> GFP_KERNEL is enough for work queue context.
> 
> As we discussed before, GFP_NOIO is required in runtime resume context
> and reset context, and the two contexts have been addressed automatically.
> So looks you didn't answer my question, :-)

Sorry, I misunderstood.

Task A					Task B				queue

queue work
						request a reset
											allocate memory and block
						cancel the work
											shit happened

	Regards
		Oliver

		
