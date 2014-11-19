From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/3] tun: move internal flag defines out of uapi
Date: Wed, 19 Nov 2014 18:50:17 +0200
Message-ID: <20141119165017.GA29759@redhat.com>
References: <1416413891-29562-1-git-send-email-mst@redhat.com>
 <1416413891-29562-2-git-send-email-mst@redhat.com>
 <1416415634.4763.9.camel@dcbw.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, rusty@rustcorp.com.au,
	davem@davemloft.net, Jason Wang <jasowang@redhat.com>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>,
	Tom Herbert <therbert@google.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Masatake YAMATO <yamato@redhat.com>, Xi Wang <xii@google.com>,
	netdev@vger.kernel.org, linux-api@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1416415634.4763.9.camel@dcbw.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 19, 2014 at 10:47:14AM -0600, Dan Williams wrote:
> On Wed, 2014-11-19 at 18:18 +0200, Michael S. Tsirkin wrote:
> > TUN_ flags are internal and never exposed
> > to userspace. Any application using it is almost
> > certainly buggy.
> 
> Except for TUN_TUN_DEV and TUN_TAP_DEV and TUN_TYPE_MASK...  which we're
> using (for some reason) in NetworkManager, though I'll happily convert
> those to IFF_* instead.  It might be worth #defining those to their
> IFF_* equivalents since their usage is not technically broken.
> 
> Dan

Hmm you are right, they happen to have the same value.
I'll send v2 leaving these in place.


> > Move them out to tun.c, we'll remove them in follow-up patches.
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > ---
> >  include/uapi/linux/if_tun.h | 14 --------------
> >  drivers/net/tun.c           | 14 ++++++++++++++
> >  2 files changed, 14 insertions(+), 14 deletions(-)
> > 
> > diff --git a/include/uapi/linux/if_tun.h b/include/uapi/linux/if_tun.h
> > index e9502dd..b82c276 100644
> > --- a/include/uapi/linux/if_tun.h
> > +++ b/include/uapi/linux/if_tun.h
> > @@ -23,20 +23,6 @@
> >  /* Read queue size */
> >  #define TUN_READQ_SIZE	500
> >  
> > -/* TUN device flags */
> > -#define TUN_TUN_DEV 	0x0001	
> > -#define TUN_TAP_DEV	0x0002
> > -#define TUN_TYPE_MASK   0x000f
> > -
> > -#define TUN_FASYNC	0x0010
> > -#define TUN_NOCHECKSUM	0x0020
> > -#define TUN_NO_PI	0x0040
> > -/* This flag has no real effect */
> > -#define TUN_ONE_QUEUE	0x0080
> > -#define TUN_PERSIST 	0x0100	
> > -#define TUN_VNET_HDR 	0x0200
> > -#define TUN_TAP_MQ      0x0400
> > -
> >  /* Ioctl defines */
> >  #define TUNSETNOCSUM  _IOW('T', 200, int) 
> >  #define TUNSETDEBUG   _IOW('T', 201, int) 
> > diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> > index 2e18ddd..81735f5 100644
> > --- a/drivers/net/tun.c
> > +++ b/drivers/net/tun.c
> > @@ -103,6 +103,20 @@ do {								\
> >  } while (0)
> >  #endif
> >  
> > +/* TUN device flags */
> > +#define TUN_TUN_DEV 	0x0001
> > +#define TUN_TAP_DEV	0x0002
> > +#define TUN_TYPE_MASK   0x000f
> > +
> > +#define TUN_FASYNC	0x0010
> > +#define TUN_NOCHECKSUM	0x0020
> > +#define TUN_NO_PI	0x0040
> > +/* This flag has no real effect */
> > +#define TUN_ONE_QUEUE	0x0080
> > +#define TUN_PERSIST 	0x0100
> > +#define TUN_VNET_HDR 	0x0200
> > +#define TUN_TAP_MQ      0x0400
> > +
> >  #define GOODCOPY_LEN 128
> >  
> >  #define FLT_EXACT_COUNT 8
> 
