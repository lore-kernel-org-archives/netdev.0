From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [take5 0/4] kevent: Generic event handling mechanism.
Date: Wed, 9 Aug 2006 09:34:01 +0100
Message-ID: <20060809083400.GA21912@infradead.org>
References: <11550230861383@2ka.mipt.ru> <44D902EF.8070809@oracle.com> <20060809053113.GB17446@2ka.mipt.ru> <20060808.225230.104030885.davem@davemloft.net> <20060809061159.GA5979@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, zach.brown@oracle.com,
	drepper@redhat.com, netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:23426 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1030458AbWHIIeM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 04:34:12 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20060809061159.GA5979@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2006 at 10:11:59AM +0400, Evgeniy Polyakov wrote:
> On Tue, Aug 08, 2006 at 10:52:30PM -0700, David Miller (davem@davemloft.net) wrote:
> > > Using LIST_POISON is a flag that kevent is in appropriate queue or not,
> > > I can add some flag into the structure, but why, if it is clear just by
> > > looking into list's pointers.
> > 
> > What is wrong with using list_empty() as this indicator?
> 
> RCU only replaces ->prev pointer, and list_empty(entry) checks for
> entry->next == head, but actually I do not see how kevent entry can
> point to itself, so I will try this.

Looking at LIST_POISON1 is still not acceptable at all.  It's an internal
implementation details that goes and comes back once in a while.  We already
had a past discussion on a use of this and it went away, maybe Andrew
can remember it.
