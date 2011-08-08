From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH v2 0/9] bql: Byte Queue Limits
Date: Mon, 8 Aug 2011 10:55:29 -0700
Message-ID: <20110808105529.4c8c52e1@nehalam.ftrdhcpuser.net>
References: <alpine.DEB.2.00.1108072129010.13386@pokey.mtv.corp.google.com>
	<20110808084016.063a0699@nehalam.ftrdhcpuser.net>
	<CA+mtBx_vgsH+uHLi6p80E8CEhU7SHXY=Fw1Z-W2OFWy44LP-ig@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39356 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751460Ab1HHRzU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 13:55:20 -0400
In-Reply-To: <CA+mtBx_vgsH+uHLi6p80E8CEhU7SHXY=Fw1Z-W2OFWy44LP-ig@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 8 Aug 2011 10:51:06 -0700
Tom Herbert <therbert@google.com> wrote:

> On Mon, Aug 8, 2011 at 8:40 AM, Stephen Hemminger <shemminger@vyatta.=
com> wrote:
> > On Sun, 7 Aug 2011 21:43:13 -0700 (PDT)
> > Tom Herbert <therbert@google.com> wrote:
> >
> >> =A0 =A0 netdev_tx_completed_queue: Called at end of transmit compl=
etion
> >> =A0 =A0 =A0 to inform stack of number of bytes and packets process=
ed.
> >> =A0 =A0 netdev_tx_sent_queue: Called to inform stack when packets =
are
> >> =A0 =A0 =A0 queued.
> >
> > Couldn't these be done for the device in the existing qdisc infra
> > structure (or dev_start_xmit). Alternatively, rename ndo_start_xmit
> > to something else and make all the callers use the wrapper.
> >
> > Changing all the drivers for something that the driver has no real
> > need to care about seems like incorrect object design.
> >
> The netdev_tx_completed_queue is needed to inform the stack of number
> of packets and bytes completed in an execution of transmit completion
> (epic).  I don't see a way to get that information outside of the
> driver.
>=20
> Tom

Since transmit completion means calling dev_kfree_skb() why not account
there? You could add some info to netdev if necessary to get compile
the statistics.

I just hate driver api complexity growth.
=20
