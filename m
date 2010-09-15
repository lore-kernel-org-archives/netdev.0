From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 2/2] macvtap: TX zero copy between guest and host
 kernel
Date: Wed, 15 Sep 2010 07:31:00 +0200
Message-ID: <20100915053059.GB25481@redhat.com>
References: <1284476719.13351.35.camel@localhost.localdomain>
 <201009141721.13202.arnd@arndb.de>
 <20100914152231.GA13105@redhat.com>
 <1284480025.13351.49.camel@localhost.localdomain>
 <20100914162952.GB13560@redhat.com>
 <1284483745.13351.71.camel@localhost.localdomain>
 <20100914182707.GB15549@redhat.com>
 <1284490143.13351.82.camel@localhost.localdomain>
 <20100914190156.GA16037@redhat.com>
 <1284492029.13351.88.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnd Bergmann <arnd@arndb.de>, Avi Kivity <avi@redhat.com>,
	"Xin, Xiaohui" <xiaohui.xin@intel.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1284492029.13351.88.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 14, 2010 at 12:20:29PM -0700, Shirley Ma wrote:
> On Tue, 2010-09-14 at 21:01 +0200, Michael S. Tsirkin wrote:
> > On Tue, Sep 14, 2010 at 11:49:03AM -0700, Shirley Ma wrote:
> > > On Tue, 2010-09-14 at 20:27 +0200, Michael S. Tsirkin wrote:
> > > > As others said, the harder issues for TX are in determining that
> > it's
> > > > safe
> > > > to unpin the memory, and how much memory is it safe to pin to
> > beging
> > > > with.  For RX we have some more complexity.
> > > 
> > > I think unpin the memory is in kfree_skb() whenever the last
> > reference
> > > is gone for TX. What we discussed about here is when/how vhost get
> > > notified to update ring buffer descriptors. Do I misunderstand
> > something
> > > here? 
> > 
> > Right, that's a better way to put it. 
> 
> That's how this macvtap patch did. For how much pinned pages,it is
> limited by sk_wmem_alloc size in this patch.
> 
> thanks
> Shirley

Except that you seem to pin full pages but account sub-page size
in wmem.

-- 
MST
