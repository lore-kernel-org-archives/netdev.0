From: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: discrepancy in ip(7) wrt. IP DF flag for UDP sockets
Date: Thu, 22 Sep 2011 06:48:27 -0400
Message-ID: <20110922104827.GA4051@hmsreliant.think-freely.org>
References: <20110919121940.GA19942@synalogic.ca>
 <20110919130313.GA27819@hmsreliant.think-freely.org>
 <CAKgNAkgWRdkxgTXNnMi4PVGGsOd-8EHF1siBrk-Bj=rnYenVmQ@mail.gmail.com>
 <20110920132954.GA23041@synalogic.ca>
 <20110920133837.GA16323@hmsreliant.think-freely.org>
 <20110920141234.GA23164@synalogic.ca>
 <20110920143109.GB16323@hmsreliant.think-freely.org>
 <CAKgNAkiSrGdXd2e1dpcC0fPmARRwkMrUvB8vCJ7eQ8SYsCuuUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benjamin Poirier <benjamin.poirier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAKgNAkiSrGdXd2e1dpcC0fPmARRwkMrUvB8vCJ7eQ8SYsCuuUw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 22, 2011 at 06:15:53AM +0200, Michael Kerrisk wrote:
> Ben, Neil,
>=20
> On Tue, Sep 20, 2011 at 4:31 PM, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> =
wrote:
> > On Tue, Sep 20, 2011 at 10:12:34AM -0400, Benjamin Poirier wrote:
> >> On 11-09-20 09:38, Neil Horman wrote:
> >> > On Tue, Sep 20, 2011 at 09:29:54AM -0400, Benjamin Poirier wrote=
:
> >> > > On 11-09-20 08:14, Michael Kerrisk wrote:
> >> > > > Hello Benjamin, Neil,
> >> > > >
> >> [snip]
> >> > > >
> >> > > > Could you describe the required change in terms of how the m=
an page
> >> > > > text should look--i.e., rewrite the passage as you think it =
should
> >> > > > look?
> >> > >
> >> > > How about changing it to:
> >> > > =A0 IP_MTU_DISCOVER (since Linux 2.2)
> >> > > =A0 Set or receive the Path MTU Discovery setting for a socket=
=2E When
> >> > > =A0 enabled, the don't-fragment flag is set on all outgoing pa=
ckets.
> >> > > =A0 Linux will perform Path MTU Discovery as defined in RFC 11=
91 on
> >> > > =A0 SOCK_STREAM sockets. For non-SOCK_STREAM sockets, it is th=
e
> >> > > =A0 user's responsibility to packetize the data in MTU sized c=
hunks
> >> > > =A0 and to do the retransmits if necessary. The kernel will re=
ject
> >> > > =A0 (with EMSGSIZE) datagrams that are bigger than the known p=
ath
> >> > > =A0 MTU. The system-wide default is controlled by the
> >> > > =A0 /proc/sys/net/ipv4/ip_no_pmtu_disc file.
> >> > >
> >> > > =A0 Path MTU discovery flags =A0 Meaning
> >> > > =A0 [...]
> >> > >
> >> > > There are some differences between _DO and _WANT that are glos=
sed over
> >> > > in this description, but I suppose there's only so much detail=
 you can
> >> > > put in...
> >> > >
> >> > > Thanks,
> >> > > -Ben
> >> > >
> >> > Yeah, I think thats close, but its only the users responsibility=
 to package
> >> > datagrams in mtu sized chunks if they force the dont fragment bi=
t on. =A0If they
> >> > go wtih the default, the stack will fragment a datagram is it se=
es fit according
> >> > to the mtu of the path it traverses
> >>
> >> Exactly. To get into this level of detail, I think we have to ment=
ion
> >> the option value, not just enabled/disabled. Let's try like this:
> >>
> >> =A0 =A0 =A0 IP_MTU_DISCOVER (since Linux 2.2)
> >> =A0 =A0 =A0 Set or receive the Path MTU Discovery setting for a so=
cket. When
> >> =A0 =A0 =A0 enabled, Linux will perform Path MTU Discovery as defi=
ned in RFC
> >> =A0 =A0 =A0 1191 on SOCK_STREAM sockets. =A0For non-SOCK_STREAM so=
ckets,
> >> =A0 =A0 =A0 IP_PMTUDISC_DO forces the don't-fragment flag to be se=
t on all
> >> =A0 =A0 =A0 outgoing packets. =A0It is the user's responsibility t=
o packetize
> >> =A0 =A0 =A0 the data in MTU sized chunks and to do the retransmits=
 if
> >> =A0 =A0 =A0 necessary. =A0The kernel will reject (with EMSGSIZE) d=
atagrams
> >> =A0 =A0 =A0 that are bigger than the known path MTU. =A0IP_PMTUDIS=
C_WANT will
> >> =A0 =A0 =A0 fragment a datagram if needed according to the path MT=
U or will
> >> =A0 =A0 =A0 set the don't-fragment flag otherwise.
> >>
> >> =A0 =A0 =A0 The system-wide default can be toggled between IP_PMTU=
DISC_WANT
> >> =A0 =A0 =A0 and IP_PMTUDISC_DONT by writting to the
> >> =A0 =A0 =A0 /proc/sys/net/ipv4/ip_no_pmtu_disc file.
> >>
> > Yes, that sounds good to me. =A0Thanks for doing this!
> > Acked-by: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
>=20
> Ben, thanks for writing this, and Neil, thanks for reviewing it. I've
> applied that change for man-pages-3.34.
>=20
> Ben, I added one small piece ti the description of
> /proc/sys/net/ipv4/ip_no_pmtu_disc. For completeness, I've reproduced
> the entire text below. Perhaps you could take a quick scan, to make
> sure that the changed text is consistent with the whole piece.
>=20
This looks good to me.  A minor nit in the chunk you added thoguh.  Cal=
ling the
MTU discovery value 'flags' suggests they can be or-together, or someho=
w
otherwise combined, which is non-sensical.  It may be better to use the=
 term
values rather than flags.

Other than that
Acked-by: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

Thanks!
Neil

--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
