From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: Re: [net-next 1/9] i40e: poll firmware slower
Date: Fri, 7 Nov 2014 15:02:23 -0800
Message-ID: <20141107150223.00004b23@unknown>
References: <1415350670-15333-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1415350670-15333-2-git-send-email-jeffrey.t.kirsher@intel.com>
	<CAJ3xEMghFwT8Tm9wONzLPL4MLvgL+3w=CNRNg0Hb=yGJ9uR0Mg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	Kamil Krawczyk <kamil.krawczyk@intel.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	<nhorman@redhat.com>, <sassmann@redhat.com>, <jogreene@redhat.com>,
	jesse.brandeburg@intel.com
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:24969 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751757AbaKGXC0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2014 18:02:26 -0500
In-Reply-To: <CAJ3xEMghFwT8Tm9wONzLPL4MLvgL+3w=CNRNg0Hb=yGJ9uR0Mg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 7 Nov 2014 15:29:15 +0200
Or Gerlitz <gerlitz.or@gmail.com> wrote:

> On Fri, Nov 7, 2014 at 10:57 AM, Jeff Kirsher
> <jeffrey.t.kirsher@intel.com> wrote:
> > The code was polling the firmware tail register for completion
> 
> any reason not to sleep while waiting for this completion? can the
> firmware generate an interrupt?

The code path in question is called from the drivers when they are in
a synchronous context and can sleep or be rescheduled without issue.
An async mode is possible, but not here, because the code complexity
required to change to async mode is unmaintainable (if even doable, how
do you handle an interrupt while you're in probe?).  We use async when
it is practical.

Thanks for your comments,
Jesse
