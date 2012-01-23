From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: RFC Hanging clean-up of a namespace
Date: Sun, 22 Jan 2012 23:55:23 -0800
Message-ID: <m1y5syq2dw.fsf@fess.ebiederm.org>
References: <20120119192541.GM2262734@jupiter.n2.diac24.net>
	<201201230758.55200.hans.schillstrom@ericsson.com>
	<m1ipk2riqb.fsf@fess.ebiederm.org>
	<201201230830.08993.hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	David Miller <davem@davemloft.net>,
	"equinox\@diac24.net" <equinox@diac24.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:60360 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750979Ab2AWHwv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 02:52:51 -0500
In-Reply-To: <201201230830.08993.hans.schillstrom@ericsson.com> (Hans
	Schillstrom's message of "Mon, 23 Jan 2012 08:30:08 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hans Schillstrom <hans.schillstrom@ericsson.com> writes:

> We  have a process in root name space (init_net) that have 
> tcp connections into a number of containers (in the same machine)
>
> If the control process in root ns dies all containers will also be killed
> i.e. there can easilly be out standing messages to and from the containers.
> So I guess that's why I see the tcp_write_timer()

The control process is an important piece of this but it should not be
sufficient to cause tcp sockets to take forever to close, as the kernel
manages sockets.  Do you shut down communication between your namespaces
before the are finished cleanup up?

The easy way to communicate between namespaces would be just to use
a veth pair and the veth pair will go away when the non init_net
container goes away.  Using a veth pair should ensure you have
communications between your namespaces so your local sockets
can shutdown quickly.

It feels like right now that whatever your shutdown/restart process
is that you are shooting yourself in the foot and triggering those
long socket close times.  I expect with a slight different order
of operations you can avoid this long shutdown problem.

Eric
