From: Kazunori Miyazawa <kazunori@miyazawa.org>
Subject: Re: [PATCH][IPV6] fixed authentication error with TCP
Date: Mon, 18 Aug 2003 18:32:45 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818183245.4fa3508e.kazunori@miyazawa.org>
References: <200308172329.DAA14889@dub.inr.ac.ru>
	<Pine.LNX.4.44.0308181029560.18400-200000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, davem@redhat.com, netdev@oss.sgi.com,
   usagi@linux-ipv6.org, latten@austin.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.44.0308181029560.18400-200000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I don't stick to chenge the interface.
I think his/her patch is better than mine. I checked and it seems to work well.
Please apply his/her patch.

On Mon, 18 Aug 2003 10:45:41 +0300 (EEST)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> On Mon, 18 Aug 2003 kuznet@ms2.inr.ac.ru wrote:
> 
> > Hello!
> >
> > > But I see a small area for improvement.  Look at the place inside
> > > of ip6_dst_lookup() where we do source address selection.  If this
> > > fails, we mark error to dst->error.
> > .....
> > > It seems to me that it is only OK for dst->error to be set on routes
> > > that may not be used validly for anything.
> > >
> > > Alexey, do I understand this stuff correctly?
> >
> > I think you do. And this is rather severe bug than area for improvement.
> > It definitely corrupts routing table.
> 
> Besides this, the patch also introduced dst_entry leaks in at least
> icmp.c, raw.c and udp.c.
> >
> > Well, I think switching from function returning error code to a function
> > returning dst is not a very good idea. This never was convenient.
> > In the case of error, IPv6 used to return to caller a dummy reject route,
> > which is always -ENETRUNREACH. So, to do this we have to hold a route
> > for each errno. Returning int was just better.
> 
> The attached patch reverts to the old ip6_dst_lookup() interface and and
> makes tcp_ipv6.c use that instead.
> 
> As an added bonus neither tcp_v6_connect() nor udpv6_connect() needs to do
> source address selection anymore, since ip6_dst_lookup() already does this
> for them.
> 
> >
> > Alexey
> 
> I've tested the patch a bit and everything seems to work normally, so its
> probably safe to apply it :)
> 
> Thanks,
> Ville
> --
> Ville Nuorvala
> Research Assistant, Institute of Digital Communications,
> Helsinki University of Technology
> email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
> 

--Kazunori Miyazawa
