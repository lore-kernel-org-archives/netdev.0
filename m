From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH net-next 6/6] net: use core MTU range checking in misc
 drivers
Date: Sat, 22 Oct 2016 20:51:57 +0200
Message-ID: <20161022205157.0b89a013@kant>
References: <20161019023333.15760-1-jarod@redhat.com>
        <20161019023333.15760-7-jarod@redhat.com>
        <20161019160546.GC11224@bistromath.localdomain>
        <20161020003846.64f85f7e@kant>
        <20161020031641.GJ18569@redhat.com>
        <20161022113607.55832988@kant>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Sabrina Dubroca <sd@queasysnail.net>, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, Faisal Latif <faisal.latif@intel.com>,
        linux-rdma@vger.kernel.org, Cliff Whickman <cpw@sgi.com>,
        Robin Holt <robinmholt@gmail.com>,
        Jes Sorensen <jes@trained-monkey.org>,
        Marek Lindner <mareklindner@neomailbox.ch>,
        Simon Wunderlich <sw@simonwunderlich.de>,
        Antonio Quartulli <a@unstable.cc>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161022113607.55832988@kant>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Oct 22 Stefan Richter wrote:
> On Oct 19 Jarod Wilson wrote:
> > On Thu, Oct 20, 2016 at 12:38:46AM +0200, Stefan Richter wrote:  
> > > On Oct 19 Sabrina Dubroca wrote:  
> > > > 2016-10-18, 22:33:33 -0400, Jarod Wilson wrote:
[...]
> > > > > @@ -1481,6 +1471,8 @@ static int fwnet_probe(struct fw_unit *unit,
> > > > >  	max_mtu = (1 << (card->max_receive + 1))
> > > > >  		  - sizeof(struct rfc2734_header) - IEEE1394_GASP_HDR_SIZE;
> > > > >  	net->mtu = min(1500U, max_mtu);
> > > > > +	net->min_mtu = ETH_MIN_MTU;
> > > > > +	net->max_mtu = net->mtu;    
> > > > 
> > > > But that will now prevent increasing the MTU above the initial value?  
> > > 
> > > Indeed, therefore NAK.  
> > 
> > However, there's an explicit calculation for 'max_mtu' right there that I
> > glazed right over. It would seem perhaps *that* should be used for
> > net->max_mtu here, no?  
> 
> No.  This 'max_mtu' here is not the absolute maximum.  It is only an
> initial MTU which has the property that link fragmentation is not
> going to happen (if all other peers will at least as capable as this
> node).

Besides, card->max_receive is about what the card can receive (at the IEEE
1394 link layer), not about what the card can send.
-- 
Stefan Richter
-======----- =-=- =-==-
http://arcgraph.de/sr/
