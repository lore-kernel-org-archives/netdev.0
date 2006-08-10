From: David Miller <davem@davemloft.net>
Subject: Re: [take6 1/3] kevent: Core files.
Date: Wed, 09 Aug 2006 23:42:35 -0700 (PDT)
Message-ID: <20060809.234235.71555079.davem@davemloft.net>
References: <11551105602734@2ka.mipt.ru>
	<20060809152127.481fb346.akpm@osdl.org>
	<20060810061433.GA4689@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, drepper@redhat.com,
	netdev@vger.kernel.org, zach.brown@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:26576
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161099AbWHJGm2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Aug 2006 02:42:28 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060810061433.GA4689@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Thu, 10 Aug 2006 10:14:33 +0400

> On Wed, Aug 09, 2006 at 03:21:27PM -0700, Andrew Morton (akpm@osdl.org) wrote:
> > On big-endian machines, this pointer will appear to be word-swapped as far
> > as a 64-bit kernel is concerned.  Or something.
> > 
> > IOW: What's going on here??
> 
> It is user data - I put there a union just to simplify userspace, so it
> sould not require some typecasting.

And this is consistent with similar mechianism we use for
netlink socket dumping, so that we don't have compat layer
crap just because we provide a place for the user to store
his pointer or whatever there.

> > > +	k->kevent_entry.next = LIST_POISON1;
> > > +	k->storage_entry.prev = LIST_POISON2;
> > > +	k->ready_entry.next = LIST_POISON1;
> > 
> > Nope ;)
> 
> I use pointer checks to determine if entry is in the list or not, why it
> is frowned upon here?

As Andrew mentioned in another posting, these poison macros
are likely to simply go away some day, so you should not use
them.

If you want pointer encoded tags you use internally, define your own.
