From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH] Subject: virtio: Add unused buffers detach from
	vring
Date: Tue, 15 Dec 2009 23:14:50 +0200
Message-ID: <20091215211450.GE26712@redhat.com>
References: <1260534506.30371.6.camel@localhost.localdomain> <1260535613.30371.24.camel@localhost.localdomain> <20091213114320.GC7074@redhat.com> <1260828518.8716.105.camel@localhost.localdomain> <20091215113327.GC13110@redhat.com> <1260894320.4387.64.camel@localhost.localdomain> <20091215163901.GA24015@redhat.com> <1260902573.4387.76.camel@localhost.localdomain> <20091215184740.GD25724@redhat.com> <1260904447.4387.85.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Anthony Liguori <anthony@codemonkey.ws>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1260904447.4387.85.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 15, 2009 at 11:14:07AM -0800, Shirley Ma wrote:
> Hello Michael,
> 
> On Tue, 2009-12-15 at 20:47 +0200, Michael S. Tsirkin wrote:
> > > +                     detach_buf(vq, i);
> > > +                     END_USE(vq);
> > > +                     return vq->data[i];
> > 
> > In fact, this will return NULL always, won't it?
> 
> Nope, I changed the destroy to detach and return the buffers without
> destroying them within the call. I thought it might be useful in some
> other case. 
> 
> Maybe I should put destroy call back?
> 
> Thanks
> Shirley

No I think it's good as is, we do not need a callback.
I was simply saying that detach_buf sets data to NULL,
so return vq->data[i] after detach does not make sense.
You need to save data as comment below says.c

-- 
MST
