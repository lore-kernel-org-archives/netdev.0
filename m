From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH v2 0/9] bql: Byte Queue Limits
Date: Mon, 8 Aug 2011 11:19:17 -0700
Message-ID: <20110808111917.4b2669de@nehalam.ftrdhcpuser.net>
References: <alpine.DEB.2.00.1108072129010.13386@pokey.mtv.corp.google.com>
	<20110808084016.063a0699@nehalam.ftrdhcpuser.net>
	<CA+mtBx_vgsH+uHLi6p80E8CEhU7SHXY=Fw1Z-W2OFWy44LP-ig@mail.gmail.com>
	<20110808105529.4c8c52e1@nehalam.ftrdhcpuser.net>
	<CA+mtBx_bdCGvR+xBMq9px0vOV6a6kFn0wYyJH26+CdSPLtvgfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:46211 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751924Ab1HHSTI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Aug 2011 14:19:08 -0400
In-Reply-To: <CA+mtBx_bdCGvR+xBMq9px0vOV6a6kFn0wYyJH26+CdSPLtvgfw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 8 Aug 2011 11:01:57 -0700
Tom Herbert <therbert@google.com> wrote:

> > Since transmit completion means calling dev_kfree_skb() why not account
> > there? You could add some info to netdev if necessary to get compile
> > the statistics.
> >
> The algorithm depends on knowing the total number of packets competed
> in a single execution of transmit completion (epic based).  We only
> want to recalculate the limits once per completion, which happens when
> the completion function is called.

So just add some stats to netdev and count the number of dev_kfree_skb
calls and do your work at napi complete.
