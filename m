From: Benjamin Poirier <benjamin.poirier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: discrepancy in ip(7) wrt. IP DF flag for UDP sockets
Date: Tue, 20 Sep 2011 10:12:34 -0400
Message-ID: <20110920141234.GA23164@synalogic.ca>
References: <20110919121940.GA19942@synalogic.ca>
 <20110919130313.GA27819@hmsreliant.think-freely.org>
 <CAKgNAkgWRdkxgTXNnMi4PVGGsOd-8EHF1siBrk-Bj=rnYenVmQ@mail.gmail.com>
 <20110920132954.GA23041@synalogic.ca>
 <20110920133837.GA16323@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110920133837.GA16323-B26myB8xz7F8NnZeBjwnZQMhkBWG/bsMQH7oEaQurus@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 11-09-20 09:38, Neil Horman wrote:
> On Tue, Sep 20, 2011 at 09:29:54AM -0400, Benjamin Poirier wrote:
> > On 11-09-20 08:14, Michael Kerrisk wrote:
> > > Hello Benjamin, Neil,
> > > 
[snip]
> > > 
> > > Could you describe the required change in terms of how the man page
> > > text should look--i.e., rewrite the passage as you think it should
> > > look?
> > 
> > How about changing it to:
> > 	IP_MTU_DISCOVER (since Linux 2.2)
> > 	Set or receive the Path MTU Discovery setting for a socket. When
> > 	enabled, the don't-fragment flag is set on all outgoing packets.
> > 	Linux will perform Path MTU Discovery as defined in RFC 1191 on
> > 	SOCK_STREAM sockets. For non-SOCK_STREAM sockets, it is the
> > 	user's responsibility to packetize the data in MTU sized chunks
> > 	and to do the retransmits if necessary. The kernel will reject
> > 	(with EMSGSIZE) datagrams that are bigger than the known path
> > 	MTU. The system-wide default is controlled by the
> > 	/proc/sys/net/ipv4/ip_no_pmtu_disc file. 
> > 
> > 	Path MTU discovery flags   Meaning
> > 	[...]
> > 
> > There are some differences between _DO and _WANT that are glossed over
> > in this description, but I suppose there's only so much detail you can
> > put in...
> > 
> > Thanks,
> > -Ben
> > 
> Yeah, I think thats close, but its only the users responsibility to package
> datagrams in mtu sized chunks if they force the dont fragment bit on.  If they
> go wtih the default, the stack will fragment a datagram is it sees fit according
> to the mtu of the path it traverses

Exactly. To get into this level of detail, I think we have to mention
the option value, not just enabled/disabled. Let's try like this:

 	IP_MTU_DISCOVER (since Linux 2.2)
	Set or receive the Path MTU Discovery setting for a socket. When
	enabled, Linux will perform Path MTU Discovery as defined in RFC
	1191 on SOCK_STREAM sockets.  For non-SOCK_STREAM sockets,
	IP_PMTUDISC_DO forces the don't-fragment flag to be set on all
	outgoing packets.  It is the user's responsibility to packetize
	the data in MTU sized chunks and to do the retransmits if
	necessary.  The kernel will reject (with EMSGSIZE) datagrams
	that are bigger than the known path MTU.  IP_PMTUDISC_WANT will
	fragment a datagram if needed according to the path MTU or will
	set the don't-fragment flag otherwise.

	The system-wide default can be toggled between IP_PMTUDISC_WANT
	and IP_PMTUDISC_DONT by writting to the
	/proc/sys/net/ipv4/ip_no_pmtu_disc file.
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
