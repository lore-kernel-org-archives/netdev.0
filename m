From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: Re: [PATCH net-next 2/8] ieee802154: add
 address struct with proper endiannes and some operations
Date: Fri, 14 Mar 2014 17:30:10 +0100
Message-ID: <20140314173010.25039487@zoidberg>
References: <1394810613-5657-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
	<1394810613-5657-3-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
	<063D6719AE5E284EB5DD2968C1650D6D0F6DDDE4@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org"
	<linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6DDDE4-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 14 Mar 2014 16:00:39 +0000
David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org> wrote:

> From: Phoebe Buckheister
> > Add a replacement ieee802154_addr struct with proper endianness on
> > fields. Short address fields are stored as __le16 as on the network,
> > extended (EUI64) addresses are __le64 as opposed to the u8[8] format
> > used previously. This disconnect with the netdev address, which is
> > stored as big-endian u8[8], is intentional.
> ...
> > +struct ieee802154_addr {
> > +	u8 mode;
> > +	__le16 pan_id;
> > +	union {
> > +		__le16 short_addr;
> > +		__le64 extended_addr;
> > +	};
> > +};
> 
> There is a lot of padding in there - especially on 64bit systems.
> You didn't make it clear where the above is used, but if it is
> passed to userspace I'd add explicit padding fields to ensure
> that the alignment is the same on all (sensible) architectures

Yes, there is. The intention for this struct was to be used only within
the stack, not to be exported to userspace - the original
ieee802154_addr (now *_sa) should be used for that for consistency. If
there was a way to fix endianness exported through visible kernel
interfaces, this struct should indeed not be used. Since I'm not sure
whether that's possible, I haven't added padding fields yet.

As explained in the cover letter, I do think we could change that, and
if we ever wanted to, now would be the time to do it. If we did, I'd
lay out the struct as u8 mode, u8 __pad1, __le16 pan_id, u32 __pad2,
and then the union.

------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
