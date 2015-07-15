From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next v7 0/4] net: Introduce protodown flag.
Date: Wed, 15 Jul 2015 14:04:01 -0400
Message-ID: <20150715180400.GF588@gospo.home.greyhouse.net>
References: <1436906602-2958-1-git-send-email-anuradhak@cumulusnetworks.com>
 <CAE4R7bC2WPDfJiT7Av8YYUybvc0D1cakKBgDsL+mystM33guFw@mail.gmail.com>
 <20150715162434.GE588@gospo.home.greyhouse.net>
 <CAE4R7bCfu6a5H-niv2h47WTYEUcH9KYys4tpLzSTNpUAnq9Hcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:34100 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592AbbGOSEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 14:04:04 -0400
Received: by qgep37 with SMTP id p37so21857624qge.1
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 11:04:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAE4R7bCfu6a5H-niv2h47WTYEUcH9KYys4tpLzSTNpUAnq9Hcw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 15, 2015 at 10:34:04AM -0700, Scott Feldman wrote:
> On Wed, Jul 15, 2015 at 9:24 AM, Andy Gospodarek
> <gospo@cumulusnetworks.com> wrote:
> > On Tue, Jul 14, 2015 at 10:08:35PM -0700, Scott Feldman wrote:
> >> On Tue, Jul 14, 2015 at 1:43 PM,  <anuradhak@cumulusnetworks.com> wrote:
> >> > From: Anuradha Karuppiah <anuradhak@cumulusnetworks.com>
> >> >
> >> > User space daemons can detect errors in the network that need to be
> >> > notified to the switch device drivers.
> >> >
> >> > Drivers can react to this error state by doing a phy-down on the
> >> > switch-port which would result in a carrier-off locally and on the directly
> >> > connected switch. Doing that would prevent loops and black-holes in the
> >> > network.
> >>
> >> Hi Anuradha,
> >>
> >> Since this is a switch-thingy, can you move this to switchdev port
> >> attribute rather than adding another ndo op?  I know you started this
> >> patch set before switchdev port attrs, but I think it's worthwhile
> >> moving it to switchdev since clearly the use-case is switch device
> >> drivers.   Let me know if you need help converting over to switchdev
> >> port attr.
> >
> > If it is switchdev-only that would prevent people from using commodity
> > hardware (classic servers + NICs) from being able to build something
> > similar to what can be done with rocker.
> 
> That's not true.  There is nothing preventing a classic NIC driver
> from implementing some/all switchdev ops if the device can do
> forwarding offload or other switchy-things.

I thought the point of the switchdev ops were to provide
offload-specific capabilities not just switch-specific functions.
Having it in switchdev seems misplaced architecturally and seems
less likely to have it accepted by NIC drivers that desire this
functionality.

> This patchset is about a switch feature (MLAG was the example
> use-case), so let's move this under switchdev.

As you have stated the need for it was evidenced when using a non-LACP
multi-chassis bond as there was no viable way to tell a device connectad
via a static bond that the traffic it received would be dropped.

Generally, the use-case for the proto-down feature is to have a way to
tell a connected device to stop sending traffic towards our device in a
particular scenario.  I'm certain there are times when an endpoint might
also want to take down an interface to get an upstream device to stop
sending traffic without dealing with all the baggage that comes with
taking an inteface admin down.
