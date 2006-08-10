From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take6 1/3] kevent: Core files.
Date: Thu, 10 Aug 2006 10:48:39 +0400
Message-ID: <20060810064839.GA11845@2ka.mipt.ru>
References: <11551105602734@2ka.mipt.ru> <20060809152127.481fb346.akpm@osdl.org> <20060810061433.GA4689@2ka.mipt.ru> <20060809.234235.71555079.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, drepper@redhat.com,
	netdev@vger.kernel.org, zach.brown@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:51170 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751187AbWHJGs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 02:48:59 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060809.234235.71555079.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2006 at 11:42:35PM -0700, David Miller (davem@davemloft.net) wrote:
> > > > +	k->kevent_entry.next = LIST_POISON1;
> > > > +	k->storage_entry.prev = LIST_POISON2;
> > > > +	k->ready_entry.next = LIST_POISON1;
> > > 
> > > Nope ;)
> > 
> > I use pointer checks to determine if entry is in the list or not, why it
> > is frowned upon here?
> 
> As Andrew mentioned in another posting, these poison macros
> are likely to simply go away some day, so you should not use
> them.

They exist for ages and sudently can go away?..
 
> If you want pointer encoded tags you use internally, define your own.

I think if I will add code like this
list_del(&k->entry);
k->entry.prev = KEVENT_POISON1;
k->entry.next = KEVENT_POISON2;

I will be suggested to make myself a lobotomy.

I have enough space in flags in each kevent, so I will use some bits there.

-- 
	Evgeniy Polyakov
