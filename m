From: Benjamin Poirier <benjamin.poirier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: discrepancy in ip(7) wrt. IP DF flag for UDP sockets
Date: Thu, 22 Sep 2011 08:44:48 -0400
Message-ID: <20110922124448.GA19801@synalogic.ca>
References: <20110919121940.GA19942@synalogic.ca>
 <20110919130313.GA27819@hmsreliant.think-freely.org>
 <CAKgNAkgWRdkxgTXNnMi4PVGGsOd-8EHF1siBrk-Bj=rnYenVmQ@mail.gmail.com>
 <20110920132954.GA23041@synalogic.ca>
 <20110920133837.GA16323@hmsreliant.think-freely.org>
 <20110920141234.GA23164@synalogic.ca>
 <20110920143109.GB16323@hmsreliant.think-freely.org>
 <CAKgNAkiSrGdXd2e1dpcC0fPmARRwkMrUvB8vCJ7eQ8SYsCuuUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CAKgNAkiSrGdXd2e1dpcC0fPmARRwkMrUvB8vCJ7eQ8SYsCuuUw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11-09-22 06:15, Michael Kerrisk wrote:
> Ben, Neil,
> 
[snip]
> 
> Ben, thanks for writing this, and Neil, thanks for reviewing it. I've
> applied that change for man-pages-3.34.
> 
> Ben, I added one small piece ti the description of
> /proc/sys/net/ipv4/ip_no_pmtu_disc. For completeness, I've reproduced
> the entire text below. Perhaps you could take a quick scan, to make
> sure that the changed text is consistent with the whole piece.
> 
> Thanks,
> 
> Michael
> 
>        IP_MTU_DISCOVER (since Linux 2.2)
>               Set or receive the Path  MTU  Discovery  setting  for  a
>               socket.   When enabled, Linux will perform Path MTU Dis-
>               covery as defined in RFC 1191  on  SOCK_STREAM  sockets.

Oops, seems like there's a repetition that crept in here. I'd keep only
the first of those two sentences:

>               For  non-SOCK_STREAM  sockets, IP_PMTUDISC_DO forces the
>               don't-fragment flag to be set on all  outgoing  packets.
>               The  don't-fragment  flag  is  set on all outgoing data-
>               grams.  It is the user's responsibility to packetize the
>               data  in  MTU-sized  chunks and to do the retransmits if
>               necessary.  The kernel will reject (with EMSGSIZE) data-
>               grams   that   are  bigger  than  the  known  path  MTU.
>               IP_PMTUDISC_WANT will  fragment  a  datagram  if  needed
>               according  to  the path MTU, or will set the don't-frag-
>               ment flag otherwise.
> 
>               The system-wide default can be toggled between IP_PMTUD-
>               ISC_WANT  and IP_PMTUDISC_DONT by writing (respectively,
>               zero      and      nonzero      values)      to      the
>               /proc/sys/net/ipv4/ip_no_pmtu_disc file.

I think it's a welcome clarification. Is is normal that IP_PMTUDISC_WANT
gets hyphenated?

> 
>               Path MTU discovery flags   Meaning

I agree with what Neil said about "flags" here. setsockopt(2) calls
these "option values".

Other than that, LGTM
Acked-by: Benjamin Poirier <benjamin.poirier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Thanks Michael,
-Ben


>               IP_PMTUDISC_WANT           Use per-route settings.
>               IP_PMTUDISC_DONT           Never do Path MTU Discovery.
>               IP_PMTUDISC_DO             Always do Path MTU Discovery.
>               IP_PMTUDISC_PROBE          Set DF but ignore Path MTU.
> 
>               When PMTU discovery is enabled, the kernel automatically
>               keeps track of the path MTU per destination host.   When
>               it  is connected to a specific peer with connect(2), the
>               currently known path MTU can be  retrieved  conveniently
>               using  the IP_MTU socket option (e.g., after an EMSGSIZE
>               error occurred).  The path MTU  may  change  over  time.
>               For  connectionless  sockets with many destinations, the
>               new MTU for a given destination  can  also  be  accessed
>               using  the  error  queue  (see IP_RECVERR).  A new error
>               will be queued for every incoming MTU update.
> 
>               While MTU discovery is in progress, initial packets from
>               datagram sockets may be dropped.  Applications using UDP
>               should be aware of this and not take it into account for
>               their packet retransmit strategy.
> 
>               To  bootstrap  the  path MTU discovery process on uncon-
>               nected sockets, it is possible to start with a big data-
>               gram  size  (up  to  64K-headers  bytes long) and let it
>               shrink by updates of the path MTU.
> 
>               To get an initial estimate of the path  MTU,  connect  a
>               datagram  socket  to  the destination address using con-
>               nect(2) and retrieve the MTU  by  calling  getsockopt(2)
>               with the IP_MTU option.
> 
>               It  is  possible  to implement RFC 4821 MTU probing with
>               SOCK_DGRAM or SOCK_RAW sockets by  setting  a  value  of
>               IP_PMTUDISC_PROBE  (available since Linux 2.6.22).  This
>               is also particularly useful for diagnostic tools such as
>               tracepath(8)  that wish to deliberately send probe pack-
>               ets larger than the observed Path MTU.
> 
> 
> -- 
> Michael Kerrisk
> Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
> Author of "The Linux Programming Interface"; http://man7.org/tlpi/
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
