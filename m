From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute PATCH 05/51] iplink_can: Prevent overstepping array
 bounds
Date: Tue, 15 Aug 2017 18:31:05 +0200
Message-ID: <20170815163105.GH16375@orbyte.nwl.cc>
References: <20170812120510.28750-1-phil@nwl.cc>
 <20170812120510.28750-6-phil@nwl.cc>
 <20170815081049.10ef8e06@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:50031 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753038AbdHOQbG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 15 Aug 2017 12:31:06 -0400
Content-Disposition: inline
In-Reply-To: <20170815081049.10ef8e06@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 15, 2017 at 08:10:49AM -0700, Stephen Hemminger wrote:
> On Sat, 12 Aug 2017 14:04:24 +0200
> Phil Sutter <phil@nwl.cc> wrote:
> 
> > can_state_names array contains at most CAN_STATE_MAX fields, so allowing
> > an index to it to be equal to that number is wrong. While here, also
> > make sure the array is indeed that big so nothing bad happens if
> > CAN_STATE_MAX ever increases.
> 
> No more speculative bug fixes.

I don't think a bit of speculation regarding forwards-compatibility is a
bad thing per se. In this case it is about the possibility for kernel
code to add a new state to enum can_state.

Older ip binaries will allow an index of CAN_STATE_MAX and therefore
access data beyond end of can-state_names array.

If you update linux headers but forget to add the new state to
can_state_names array, the same will happen even if the sanity check for
'state' value is being fixed as by my patch.

By specifying the size of can_state_names array upon definition,
can_print_opt() will just print a null pointer which printf() can
handle.

Cheers, Phil
