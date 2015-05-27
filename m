From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] sctp: Fix mangled IPv4 addresses on a IPv6 listening
 socket
Date: Wed, 27 May 2015 16:41:18 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB40E15@AcuExch.aculab.com>
References: <20150526233017.GB22391@obsidianresearch.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB408FE@AcuExch.aculab.com>
 <55658F9D.6030404@iogearbox.net>
 <063D6719AE5E284EB5DD2968C1650D6D1CB409AD@AcuExch.aculab.com>
 <20150527153226.GA9909@obsidianresearch.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CB40D32@AcuExch.aculab.com>
 <20150527163157.GA15041@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: 'Daniel Borkmann' <daniel@iogearbox.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Jason Gunthorpe' <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.182]:51568 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752374AbbE0QnE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 12:43:04 -0400
In-Reply-To: <20150527163157.GA15041@obsidianresearch.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Gunthorpe
> Sent: 27 May 2015 17:32
> On Wed, May 27, 2015 at 04:16:44PM +0000, David Laight wrote:
> > From: Jason Gunthorpe
> > > Sent: 27 May 2015 16:32
> > > On Wed, May 27, 2015 at 10:11:22AM +0000, David Laight wrote:
> > >
> > > > In any case it looks like I can escape by turning off
> > > > SCTP_I_WANT_MAPPED_V4_ADDR for kernels 3.17 through 4.0.
> > >
> > > Just be aware that option is unusable on kernels without 299ee.
> > >
> > > I fixed everything wrong I saw, but that doesn't mean it works
> > > 100%. Honestly, I don't think anyone has ever used it.
> >
> > I'm now confused.
> >
> > I've just done a test using a 4.0.0-rc1 kernel.
> > I'm binding an IPv6 listening socket and then connecting to it
> > from 127.0.0.1.
> > I don't know it I'm being given an IPv4 format address or a
> > v6mapped one (I shorten the latter before tracing it) - but
> > it contains 127.0.0.1 (not 0.0.0.0).
> > (That is without changing any socket options.)
> 
> I don't know what your test does, but I used the same basic idea with
> loopback to find this issue. You should confirm the kernel is
> returning a AF_INET6 socket type, if it is AF_INET then there is a
> path I missed in 299ee and I should fix it..

The code will be sleeping in kernel_accept() and later calls
kernel_getpeername().
The code is used for both TCP and SCTP and this part is common (using
the TCP semantics).

I'll look at the actual raw address format tomorrow.
I suspect it is already AF_INET6 before getting to the code that would
badly translate it.

	David
