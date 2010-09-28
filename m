From: David Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: IGMP v3 reponse
Date: Mon, 27 Sep 2010 17:41:57 -0700
Message-ID: <OF080A5D13.27F9E9BB-ON882577AC.00037A62-882577AC.0003D9E8@us.ibm.com>
References: <20100927200500.GB25879@obsidianresearch.com> <OF056C7E7C.A9A5EFC7-ON882577AB.006E6B89-882577AB.006F2C1E@us.ibm.com> <alpine.DEB.2.00.1009271521510.14117@router.home> <4CA1048C.8020508@rincon.com> <OF9D99FA29.B3F53176-ON882577AB.00780023-882577AB.0078FAAE@us.ibm.com> <4CA12DF3.6050608@rincon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Bob Arendt <rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4CA12DF3.6050608-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Bob Arendt <rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org> wrote on 09/27/2010 04:51:15 PM:

> Per rfc 2236, the v2 client *can't* drop the IGMPv3 query.  From para 
2.5:
>    2.5.  Other fields
>     Note that IGMP messages may be longer than 8 octets, especially
>     future backwards-compatible versions of IGMP.  As long as the Type 
is
>     one that is recognized, an IGMPv2 implementation MUST ignore 
anything
>     past the first 8 octets while processing the packet.  However, the
>     IGMP checksum is always computed over the whole IP payload, not just
>     over the first 8 octets.
> 
> The IGMPv3 query *is* a valid v2 query with extra crap at the end (it's
> backward compatible).  Per rfc 2236 p2.5, the v3 query has to be 
regarded
> as a valid v2 query if you're correctly implementing IGMPv2.  Some 
switch
> vendors (Cisco for one) only generate v3 queries when operating as an
> IGMP snooping switch, since a proper v2 client will respond with IGMPv2
> packets and it handles this properly.  However, we're seeing some 
switches
> get confused when a client initial joins with v2, then responds to a 
query
> with v3.  It ends up creating 2 entries, and only one is cleared by the
> leave message.  This is also an issue when the primary (querier) switch
> only generates v3 queries, and some intermediate switches only support 
v2.
> We set all the Linux clients to v2 .. but they respond the v2 query with
> v3 protocols, which could be missed by the intermediate switch.
> 
> I believe the intent of the bug 18212 patch is correct.

Bob,
        That would've been a nice quote for the other discussion; I didn't
do the v2 implementation for Linux, but it appears I broke this. I'll
take another look (and thanks for pointing that out!).

                                                        +-DLS

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
