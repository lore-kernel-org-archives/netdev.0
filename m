From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 3/3] xfrm: Fix null pointer dereference when decoding sessions
Date: Tue, 3 Dec 2013 11:41:31 +0100
Message-ID: <20131203104130.GA8920@order.stressinduktion.org>
References: <1383294107-7509-4-git-send-email-steffen.klassert@secunet.com> <20131201.203506.1790384137281236147.davem@davemloft.net> <20131203095645.GS31491@secunet.com> <2526311.Qy2u417McY@h2o.as.studentenwerk.mhn.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	mschiffer@universe-factory.net, stable@vger.kernel.org
To: Wolfgang Walter <linux@stwm.de>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2526311.Qy2u417McY@h2o.as.studentenwerk.mhn.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 03, 2013 at 11:37:04AM +0100, Wolfgang Walter wrote:
> Am Dienstag, 3. Dezember 2013, 10:56:45 schrieb Steffen Klassert:
> > Ccing stable.
> > 
> > On Sun, Dec 01, 2013 at 08:35:06PM -0500, David Miller wrote:
> > > From: Matthias Schiffer <mschiffer@universe-factory.net>
> > > Date: Sun, 01 Dec 2013 05:19:53 +0100
> > > 
> > > > On 11/24/2013 03:27 PM, Matthias Schiffer wrote:
> > > >> On 11/01/2013 09:21 AM, Steffen Klassert wrote:
> > > >>> On some codepaths the skb does not have a dst entry
> > > >>> when xfrm_decode_session() is called. So check for
> > > >>> a valid skb_dst() before dereferencing the device
> > > >>> interface index. We use 0 as the device index if
> > > >>> there is no valid skb_dst(), or at reverse decoding
> > > >>> we use skb_iif as device interface index.
> > > >>> 
> > > >>> Bug was introduced with git commit bafd4bd4dc
> > > >>> ("xfrm: Decode sessions with output interface.").
> > > >>> 
> > > >>> Reported-by: Meelis Roos <mroos@linux.ee>
> > > >>> Tested-by: Meelis Roos <mroos@linux.ee>
> > > >>> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> > > >> 
> > > >> Please queue this for 3.12-stable, I've seen this bug trigger a panic
> > > >> when heavily using Bittorrent (screenshot:
> > > >> http://i.imgur.com/OIKVccM.jpg )
> > > >> 
> > > >> Thanks,
> > > >> Matthias
> > > > 
> > > > Ping? Several people I know have hit this panic with 3.12.x at least
> > > > once or twice by now during heavy IPv6 usage.
> > > 
> > > Steffen submitted it to stable@vger.kernel.org for inclusion on Monday
> > > November 25th.
> > 
> > It apparently did not make it into v3.12.2 and it is not in the v3.12.3
> > review included. So I wonder if I need to do anything additional to
> > get it included. It is the first time that I did a stable submission
> > myself.
> > 
> > I tried to follow the instructions at Documentation/stable_kernel_rules.txt
> > but maybe I've missed something.
> 
> There is another weakness with ipv6 in 3.12.x which - under certain 
> circumstances - can be exploited remotely:
> 
> 	ipv6 fragmentation-related panic in netfilter
> 
> I would be very glad if this would make it into 3.12 stable soon.

These patches are already queued up for stable by David:
http://patchwork.ozlabs.org/bundle/davem/stable/?state=*

Greetings,

  Hannes
