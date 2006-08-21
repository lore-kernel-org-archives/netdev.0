From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take12 3/3] kevent: Timer notifications.
Date: Mon, 21 Aug 2006 16:09:34 +0400
Message-ID: <20060821120934.GA13399@2ka.mipt.ru>
References: <11561555893621@2ka.mipt.ru> <1156155589287@2ka.mipt.ru> <20060821111239.GA30945@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>, tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:52934 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S965069AbWHUMKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2006 08:10:12 -0400
To: Christoph Hellwig <hch@infradead.org>
Content-Disposition: inline
In-Reply-To: <20060821111239.GA30945@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2006 at 12:12:39PM +0100, Christoph Hellwig (hch@infradead.org) wrote:
> > +static int __init kevent_init_timer(void)
> > +{
> > +	struct kevent_callbacks tc = {
> > +		.callback = &kevent_timer_callback, 
> > +		.enqueue = &kevent_timer_enqueue, 
> > +		.dequeue = &kevent_timer_dequeue};
> 
> I think this should be static, and the normal style to write it would be:
> 
> static struct kevent_callbacks tc = {
> 	.callback	= kevent_timer_callback,
> 	.enqueue	= kevent_timer_enqueue,
> 	.dequeue	= kevent_timer_dequeue,
> };
> 
> also please consider makring all the kevent_callbacks structs const
> to avoid false cacheline sharing and accidental modification, similar
> to what we did to various other operation vectors.

Actually I do not think it should be static, since it is only used for
initialization and it's members are copied into main structure.

-- 
	Evgeniy Polyakov
