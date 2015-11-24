From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Tue, 24 Nov 2015 09:32:11 -0800
Message-ID: <CALx6S36vQhx+iKP9VcpqPBnN7VjBsgd_dYFOfZ+YHyVa97-ajA@mail.gmail.com>
References: <1448312579-159544-1-git-send-email-anjali.singhai@intel.com>
	<1448312579-159544-2-git-send-email-anjali.singhai@intel.com>
	<CALx6S34+_AtjO94znh7vW4py5a8Nj1g6b-sjGPCa4U1Mc6Y6-w@mail.gmail.com>
	<CAEh+42jWN961Gg59xbdXiFj9u7=3vuFdyXkcr6iPJ92ZizPpGw@mail.gmail.com>
	<C40BE8378EF49C44B9184714DBC8EF29939A13AA@ORSMSX115.amr.corp.intel.com>
	<CALx6S36H4eyDg-Vv21X2GaGA+g=KfN6iHX=8uM2isEOnPTjs0Q@mail.gmail.com>
	<20151123171103.00007699@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Singhai, Anjali" <anjali.singhai@intel.com>,
	Jesse Gross <jesse@kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Patil, Kiran" <kiran.patil@intel.com>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:35853 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753897AbbKXRcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 12:32:12 -0500
Received: by igcph11 with SMTP id ph11so77325303igc.1
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 09:32:12 -0800 (PST)
In-Reply-To: <20151123171103.00007699@unknown>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> FWIW, I've brought the issue to the attention of the architects here,
> and we will likely be able to make changes in this space.  Intel
> hardware (as demonstrated by your patches) already is able to deal with
> this de-ossification on transmit.  Receive is a whole different beast.
>
Please provide the specifics on why "Receive is a whole different
beast.". Generic receive checksum is already a subset of the
functionality that you must have implement to support the protocol
specific offloads. All the hardware needs to do is calculate the 1's
complement checksum of the packet and return the value on the to the
host with that packet. That's it. No parsing of headers, no worrying
about the pseudo header, no dealing with any encapsulation. Just do
the calculation, return the result to the host and the driver converts
this to CHECKSUM_COMPLETE. I find it very hard to believe that this is
any harder than specific support the next protocol du jour.

> I think that trying to force an agenda with no fore-warning and also
> punishing the users in order to get hardware vendors to change is the
> wrong way to go about this.  All you end up with is people just asking
> you why their hardware doesn't work in the kernel.
>
As you said this in only feedback and nobody is forcing anyone to do
anything. But encouraging HW vendors to provide generic mechanisms so
that your users can use whatever protocol they want is the exact
_opposite_ of punishing users, this is very much a pro-user direction.

> You have a proposal, let's codify it and enable it for the future, and
> especially be *really* clear what you want hardware vendors to
> implement so that they get it right.  MS does this by publishing
> specifications and being clear what MUST be implemented and what COULD
> be implemented.
>

Linux does not mandate HW implementation like MS, what we we do is
define driver interfaces which allow for a variety of different HW
implementations. The stack-driver checksum interface is described at
the top of skbuff.h. If this interface description is not clear enough
please let me know and we can fix that. If it is helpful we can
publish our requirements of new NICs at Facebook for reference.

Tom
