From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V4 5/8]macvtap: macvtap TX zero-copy support
Date: Wed, 4 May 2011 19:14:40 +0300
Message-ID: <20110504161440.GD15648@redhat.com>
References: <1304496893.20660.88.camel@localhost.localdomain>
 <20110504145819.GA15648@redhat.com>
 <1304523449.7076.30.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1304523449.7076.30.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 04, 2011 at 08:37:29AM -0700, Shirley Ma wrote:
> On Wed, 2011-05-04 at 17:58 +0300, Michael S. Tsirkin wrote:
> > On Wed, May 04, 2011 at 01:14:53AM -0700, Shirley Ma wrote:
> > > Only when buffer size is greater than GOODCOPY_LEN (256), macvtap
> > > enables zero-copy.
> > > 
> > > Signed-off-by: Shirley Ma <xma@us.ibm.com>
> > 
> > 
> > Looks good. Some thoughts below.
> > 
> > > ---
> > > 
> > >  drivers/net/macvtap.c |  126
> > ++++++++++++++++++++++++++++++++++++++++++++----
> > >  1 files changed, 115 insertions(+), 11 deletions(-)
> > > 
> > > diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> > > index 6696e56..e8bc5ff 100644
> > > --- a/drivers/net/macvtap.c
> > > +++ b/drivers/net/macvtap.c
> > > @@ -60,6 +60,7 @@ static struct proto macvtap_proto = {
> > >   */
> > >  static dev_t macvtap_major;
> > >  #define MACVTAP_NUM_DEVS 65536
> > > +#define GOODCOPY_LEN 256
> > 
> > Scope with MACVTAP_ please.
> Ok.
> 
> > For small packets, is it better to copy in vhost
> > and skip all the back and forth with callbacks? If yes, does
> > it make sense to put the constant above in some header
> > shared with vhost-net?
> 
> skb is created in macvtap, the small packet copy is in skb, so I don't
> think we can do it in vhost here.

BTW this is not very important, it might or might not
result in some speedup. Let's focus on getting it working
right.

-- 
MST
