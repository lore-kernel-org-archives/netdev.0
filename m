From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [NET-NEXT PATCH 08/14] e1000e: link up/down messages must
 follow a specific format
Date: Fri, 21 Nov 2008 12:16:25 -0800
Message-ID: <20081121121625.6cdf22b6@extreme>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
	<20081121190110.32313.43591.stgit@gitlost.lost>
	<1227294295.23438.17.camel@localhost.localdomain>
	<9929d2390811211123i284a3939lf96e53208ee8357e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Dan Williams" <dcbw@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org, jeff@garzik.org,
	"Bruce Allan" <bruce.w.allan@intel.com>
To: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59934 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753855AbYKUUQa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2008 15:16:30 -0500
In-Reply-To: <9929d2390811211123i284a3939lf96e53208ee8357e@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Nov 2008 11:23:42 -0800
"Jeff Kirsher" <jeffrey.t.kirsher@intel.com> wrote:

> On Fri, Nov 21, 2008 at 11:04 AM, Dan Williams <dcbw@redhat.com> wrote:
> > On Fri, 2008-11-21 at 11:01 -0800, Jeff Kirsher wrote:
> >> From: Bruce Allan <bruce.w.allan@intel.com>
> >>
> >> The system log messages created on a link status change need to follow a
> >> specific format to work with tools some customers use.
> >
> > Um, shouldn't those tools be listening to netlink for carrier events, or
> > are these tools run on a separate machine using on some later date using
> > the logs from the machine with the e1000e?
> >
> > Dan
> >
> 
> From my understanding these tools are looking at the logs and that is
> why we need to have a consistent log message.
> 

These tools are tied to a specific driver (yours), because not all drivers
generate a message or the same format message. This may be okay for Intel
but is really stupid design...

It would be good if link state transitions generated uevents (online/offline).
Then udev, hal and others could use that without netlink.
