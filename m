From: steve@chygwyn.com
Subject: Re: [RFC 1/2] net: Introduce recvmmsg socket syscall
Date: Fri, 22 May 2009 09:32:27 +0100
Message-ID: <20090522083227.GB15578@fogou.chygwyn.com>
References: <20090520230652.GB5956@ghostprotocols.net> <469958e00905210938s371b5dect28c7b1f8bb751ad1@mail.gmail.com> <20090521165515.GK5956@ghostprotocols.net> <469958e00905211026q468de6fbh2b5932d177b7c7a9@mail.gmail.com> <20090521175122.GL5956@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Caitlin Bestler <caitlin.bestler@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chris Van Hoof <vanhoof@redhat.com>,
	Clark Williams <williams@redhat.com>
To: Arnaldo Carvalho de Melo <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fogou.chygwyn.com ([195.171.2.24]:59178 "EHLO fogou.chygwyn.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751608AbZEVIjN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 May 2009 04:39:13 -0400
Content-Disposition: inline
In-Reply-To: <20090521175122.GL5956@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Thu, May 21, 2009 at 02:51:22PM -0300, Arnaldo Carvalho de Melo wrote:
> Em Thu, May 21, 2009 at 10:26:58AM -0700, Caitlin Bestler escreveu:
> > On Thu, May 21, 2009 at 9:55 AM, Arnaldo Carvalho de Melo
> > <acme@ghostprotocols.net> wrote:
> > 
> > >
> > > I.e. recvmmsg would save the value of sk->sk_rcvtimeo at entry and
> > > restore at exit, and would somehow go on subtracting the time
> > > sock_recvmsg() took from it so that the following call finds a reduced
> > > sk->sk_rcvtimeo iif it was configured in the first place and the socket
> > > is in blocking mode.
> > >
> > > How does that sound?
> > >
> > 
> > I suspect that an additional timeout value will be needed ultimately.
> 
> So you mean we need a timeout to wait for a datagram, that remains being
> sk->sk_rcvtimeo (SO_RCVTIMEO), and one that is passed as a parameter to
> recvmmsg?
>
The other thing which might also need looking at is the low water mark,
should that apply to each individual message, or to all the received messages
in combination? I think the latter is more useful.

Steve.
