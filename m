From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: RFC Hanging clean-up of a namespace
Date: Mon, 23 Jan 2012 07:58:54 +0100
Message-ID: <201201230758.55200.hans.schillstrom@ericsson.com>
References: <20120119192541.GM2262734@jupiter.n2.diac24.net> <201201230707.33761.hans.schillstrom@ericsson.com> <m1aa5frl3j.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>,
	"equinox@diac24.net" <equinox@diac24.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:63174 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750982Ab2AWG66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 01:58:58 -0500
In-Reply-To: <m1aa5frl3j.fsf@fess.ebiederm.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 23 January 2012 07:25:52 Eric W. Biederman wrote:
> Hans Schillstrom <hans.schillstrom@ericsson.com> writes:
> 
> > On Friday 20 January 2012 21:55:27 Eric W. Biederman wrote:
> >> My current hypothesis is that the namespace actually didn't get freed
> >> until the tcp socket finished closing.  You can check by looking at when
> >> __put_net and then cleanup_net are called.
> >
> > __put_net() is called just after tcp_write_timer() fires and then
> > cleanup_net()
> 
> Hypothesis confirmed.  Your speed problem is that it is taking 2 minutes
> in the pathological case for your tcp socket to close.
> 
> Do you have any clue why it is taking your sockets so long to close?
> Is the other side simply not responding?
> 

The root cause of death is that the other side (init_net namespace) dies first 
and when it dies all containers will be killed ...

/Hans
