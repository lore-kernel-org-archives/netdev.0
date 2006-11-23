From: Hans Henrik Happe <hhh@imada.sdu.dk>
Subject: Re: [take25 1/6] kevent: Description.
Date: Thu, 23 Nov 2006 22:49:56 +0100
Message-ID: <200611232249.56886.hhh@imada.sdu.dk>
References: <11641265982190@2ka.mipt.ru> <20061123115504.GB20294@2ka.mipt.ru> <4565FDED.2050003@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from berlioz.imada.sdu.dk ([130.225.128.12]:20461 "EHLO
	berlioz.imada.sdu.dk") by vger.kernel.org with ESMTP
	id S1757483AbWKWVuB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Nov 2006 16:50:01 -0500
To: Ulrich Drepper <drepper@redhat.com>
In-Reply-To: <4565FDED.2050003@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 23 November 2006 21:00, Ulrich Drepper wrote:
> Evgeniy Polyakov wrote:
> > uidx is an index, starting from which there are unread entries. It is
> > updated by userspace when it commits entries, so it is 'consumer'
> > pointer, while kidx is an index where kernel will put new entries, i.e.
> > 'producer' index. We definitely need them both.
> > Userspace can only update (implicitly by calling kevent_commit()) uidx.
> 
> Right, which is why exporting this entry is not needed.  Keep the 
> interface as small as possible.
> 
> Userlevel has to maintain its own index.  Just assume kevent_wait 
> returns 10 new entries and you have multiple threads.  In this case all 
> threads take their turns and pick an entry from the ring buffer.  This 
> basically has to be done with something like this (I ignore wrap-arounds 
> here to simplify the example):
> 
>    int getidx() {
>      while (uidx < kidx)
>         if (atomic_cmpxchg(uidx, uidx + 1, uidx) == 0)
>           return uidx;
>      return -1;
>    }

I don't know if this falls under the simplification, but wouldn't there be a 
race when reading/copying the event data? I guess this could be solved with 
an extra user index. 

--

Hans Henrik Happe 
