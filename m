From: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: discrepancy in ip(7) wrt. IP DF flag for UDP sockets
Date: Thu, 22 Sep 2011 06:15:53 +0200
Message-ID: <CAKgNAkiSrGdXd2e1dpcC0fPmARRwkMrUvB8vCJ7eQ8SYsCuuUw@mail.gmail.com>
References: <20110919121940.GA19942@synalogic.ca> <20110919130313.GA27819@hmsreliant.think-freely.org>
 <CAKgNAkgWRdkxgTXNnMi4PVGGsOd-8EHF1siBrk-Bj=rnYenVmQ@mail.gmail.com>
 <20110920132954.GA23041@synalogic.ca> <20110920133837.GA16323@hmsreliant.think-freely.org>
 <20110920141234.GA23164@synalogic.ca> <20110920143109.GB16323@hmsreliant.think-freely.org>
Reply-To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Benjamin Poirier <benjamin.poirier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110920143109.GB16323-B26myB8xz7F8NnZeBjwnZQMhkBWG/bsMQH7oEaQurus@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ben, Neil,

On Tue, Sep 20, 2011 at 4:31 PM, Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wr=
ote:
> On Tue, Sep 20, 2011 at 10:12:34AM -0400, Benjamin Poirier wrote:
>> On 11-09-20 09:38, Neil Horman wrote:
>> > On Tue, Sep 20, 2011 at 09:29:54AM -0400, Benjamin Poirier wrote:
>> > > On 11-09-20 08:14, Michael Kerrisk wrote:
>> > > > Hello Benjamin, Neil,
>> > > >
>> [snip]
>> > > >
>> > > > Could you describe the required change in terms of how the man=
 page
>> > > > text should look--i.e., rewrite the passage as you think it sh=
ould
>> > > > look?
>> > >
>> > > How about changing it to:
>> > > =A0 IP_MTU_DISCOVER (since Linux 2.2)
>> > > =A0 Set or receive the Path MTU Discovery setting for a socket. =
When
>> > > =A0 enabled, the don't-fragment flag is set on all outgoing pack=
ets.
>> > > =A0 Linux will perform Path MTU Discovery as defined in RFC 1191=
 on
>> > > =A0 SOCK_STREAM sockets. For non-SOCK_STREAM sockets, it is the
>> > > =A0 user's responsibility to packetize the data in MTU sized chu=
nks
>> > > =A0 and to do the retransmits if necessary. The kernel will reje=
ct
>> > > =A0 (with EMSGSIZE) datagrams that are bigger than the known pat=
h
>> > > =A0 MTU. The system-wide default is controlled by the
>> > > =A0 /proc/sys/net/ipv4/ip_no_pmtu_disc file.
>> > >
>> > > =A0 Path MTU discovery flags =A0 Meaning
>> > > =A0 [...]
>> > >
>> > > There are some differences between _DO and _WANT that are glosse=
d over
>> > > in this description, but I suppose there's only so much detail y=
ou can
>> > > put in...
>> > >
>> > > Thanks,
>> > > -Ben
>> > >
>> > Yeah, I think thats close, but its only the users responsibility t=
o package
>> > datagrams in mtu sized chunks if they force the dont fragment bit =
on. =A0If they
>> > go wtih the default, the stack will fragment a datagram is it sees=
 fit according
>> > to the mtu of the path it traverses
>>
>> Exactly. To get into this level of detail, I think we have to mentio=
n
>> the option value, not just enabled/disabled. Let's try like this:
>>
>> =A0 =A0 =A0 IP_MTU_DISCOVER (since Linux 2.2)
>> =A0 =A0 =A0 Set or receive the Path MTU Discovery setting for a sock=
et. When
>> =A0 =A0 =A0 enabled, Linux will perform Path MTU Discovery as define=
d in RFC
>> =A0 =A0 =A0 1191 on SOCK_STREAM sockets. =A0For non-SOCK_STREAM sock=
ets,
>> =A0 =A0 =A0 IP_PMTUDISC_DO forces the don't-fragment flag to be set =
on all
>> =A0 =A0 =A0 outgoing packets. =A0It is the user's responsibility to =
packetize
>> =A0 =A0 =A0 the data in MTU sized chunks and to do the retransmits i=
f
>> =A0 =A0 =A0 necessary. =A0The kernel will reject (with EMSGSIZE) dat=
agrams
>> =A0 =A0 =A0 that are bigger than the known path MTU. =A0IP_PMTUDISC_=
WANT will
>> =A0 =A0 =A0 fragment a datagram if needed according to the path MTU =
or will
>> =A0 =A0 =A0 set the don't-fragment flag otherwise.
>>
>> =A0 =A0 =A0 The system-wide default can be toggled between IP_PMTUDI=
SC_WANT
>> =A0 =A0 =A0 and IP_PMTUDISC_DONT by writting to the
>> =A0 =A0 =A0 /proc/sys/net/ipv4/ip_no_pmtu_disc file.
>>
> Yes, that sounds good to me. =A0Thanks for doing this!
> Acked-by: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

Ben, thanks for writing this, and Neil, thanks for reviewing it. I've
applied that change for man-pages-3.34.

Ben, I added one small piece ti the description of
/proc/sys/net/ipv4/ip_no_pmtu_disc. For completeness, I've reproduced
the entire text below. Perhaps you could take a quick scan, to make
sure that the changed text is consistent with the whole piece.

Thanks,

Michael

       IP_MTU_DISCOVER (since Linux 2.2)
              Set or receive the Path  MTU  Discovery  setting  for  a
              socket.   When enabled, Linux will perform Path MTU Dis-
              covery as defined in RFC 1191  on  SOCK_STREAM  sockets.
              For  non-SOCK_STREAM  sockets, IP_PMTUDISC_DO forces the
              don't-fragment flag to be set on all  outgoing  packets.
              The  don't-fragment  flag  is  set on all outgoing data-
              grams.  It is the user's responsibility to packetize the
              data  in  MTU-sized  chunks and to do the retransmits if
              necessary.  The kernel will reject (with EMSGSIZE) data-
              grams   that   are  bigger  than  the  known  path  MTU.
              IP_PMTUDISC_WANT will  fragment  a  datagram  if  needed
              according  to  the path MTU, or will set the don't-frag-
              ment flag otherwise.

              The system-wide default can be toggled between IP_PMTUD-
              ISC_WANT  and IP_PMTUDISC_DONT by writing (respectively,
              zero      and      nonzero      values)      to      the
              /proc/sys/net/ipv4/ip_no_pmtu_disc file.

              Path MTU discovery flags   Meaning
              IP_PMTUDISC_WANT           Use per-route settings.
              IP_PMTUDISC_DONT           Never do Path MTU Discovery.
              IP_PMTUDISC_DO             Always do Path MTU Discovery.
              IP_PMTUDISC_PROBE          Set DF but ignore Path MTU.

              When PMTU discovery is enabled, the kernel automatically
              keeps track of the path MTU per destination host.   When
              it  is connected to a specific peer with connect(2), the
              currently known path MTU can be  retrieved  conveniently
              using  the IP_MTU socket option (e.g., after an EMSGSIZE
              error occurred).  The path MTU  may  change  over  time.
              For  connectionless  sockets with many destinations, the
              new MTU for a given destination  can  also  be  accessed
              using  the  error  queue  (see IP_RECVERR).  A new error
              will be queued for every incoming MTU update.

              While MTU discovery is in progress, initial packets from
              datagram sockets may be dropped.  Applications using UDP
              should be aware of this and not take it into account for
              their packet retransmit strategy.

              To  bootstrap  the  path MTU discovery process on uncon-
              nected sockets, it is possible to start with a big data-
              gram  size  (up  to  64K-headers  bytes long) and let it
              shrink by updates of the path MTU.

              To get an initial estimate of the path  MTU,  connect  a
              datagram  socket  to  the destination address using con-
              nect(2) and retrieve the MTU  by  calling  getsockopt(2)
              with the IP_MTU option.

              It  is  possible  to implement RFC 4821 MTU probing with
              SOCK_DGRAM or SOCK_RAW sockets by  setting  a  value  of
              IP_PMTUDISC_PROBE  (available since Linux 2.6.22).  This
              is also particularly useful for diagnostic tools such as
              tracepath(8)  that wish to deliberately send probe pack-
              ets larger than the observed Path MTU.


--=20
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface"; http://man7.org/tlpi/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
