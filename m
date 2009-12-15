From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: PATCH v2 3/4] Defer skb allocation -- new recvbuf alloc &
	receive calls
Date: Tue, 15 Dec 2009 18:39:01 +0200
Message-ID: <20091215163901.GA24015@redhat.com>
References: <1258697359.7416.14.camel@localhost.localdomain> <200911231123.18898.rusty@rustcorp.com.au> <20091208122134.GA17286@redhat.com> <1260534506.30371.6.camel@localhost.localdomain> <1260535613.30371.24.camel@localhost.localdomain> <20091213114320.GC7074@redhat.com> <1260828518.8716.105.camel@localhost.localdomain> <20091215113327.GC13110@redhat.com> <1260894320.4387.64.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Anthony Liguori <anthony@codemonkey.ws>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35689 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752880AbZLOQl6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2009 11:41:58 -0500
Content-Disposition: inline
In-Reply-To: <1260894320.4387.64.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 15, 2009 at 08:25:20AM -0800, Shirley Ma wrote:
> On Tue, 2009-12-15 at 13:33 +0200, Michael S. Tsirkin wrote:
> > So what I would suggest is, have function
> > that just copies part of skb, and have
> > caller open-code allocating the skb and free up
> > pages as necessary.
> Yes, the updated patch has changed the function.
> 
> > What I am asking is why do we add skb in vi->recv.
> > Can't we use vq destoy hack here as well?
> Yes, I removed recv queue skb link totally in the updated patch.
> 
> > > One is for big packet virtio_net_hdr, one is for goodcopy skb.
> > 
> > 
> > Maybe put this in a comment then.
> Ok, will do.
> 
> > 
> > I mean the for loop: can i be for(i = 0, ..., ++i) just as well?
> > Why do you start at the end of buffer and decrement?
> 
> Are asking why reverse order for new page to sg? The reason is we link
> the new page in first, and only maintain the first pointer. So the most
> recent new page should be related to sg[0], if we put the new page in
> the last, then we need to travel the page list to get last pointer. Am I
> missing your point here?
> 
> Thanks
> Shirley 


No, that was what I was looking for.

