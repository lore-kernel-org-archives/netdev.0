From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] [RFC PATCH V3 12/16] netback: multi-page ring
 support
Date: Tue, 31 Jan 2012 09:01:52 +0000
Message-ID: <4F27BC1002000078000700D3@nat28.tlf.novell.com>
References: <1327934734-8908-1-git-send-email-wei.liu2@citrix.com>
 <1327934734-8908-13-git-send-email-wei.liu2@citrix.com>
 <4F26D4E5020000780006FF41@nat28.tlf.novell.com>
 <1327943436.5553.39.camel@leeds.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: "Ian Campbell" <Ian.Campbell@citrix.com>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Wei Liu" <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:51948 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752289Ab2AaJB6 convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:4:1>);
	Tue, 31 Jan 2012 04:01:58 -0500
In-Reply-To: <1327943436.5553.39.camel@leeds.uk.xensource.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 30.01.12 at 18:10, Wei Liu <wei.liu2@citrix.com> wrote:
> On Mon, 2012-01-30 at 16:35 +0000, Jan Beulich wrote:
>> >>> On 30.01.12 at 15:45, Wei Liu <wei.liu2@citrix.com> wrote:
>> > -int xenvif_map_frontend_rings(struct xenvif *vif,
>> > -			      grant_ref_t tx_ring_ref,
>> > -			      grant_ref_t rx_ring_ref)
>> > +int xenvif_map_frontend_rings(struct xen_comms *comms,
>> > +			      int domid,
>> > +			      unsigned long ring_ref[],
>> > +			      unsigned int  ring_ref_count)
>> >  {
>> > -	void *addr;
>> > -	struct xen_netif_tx_sring *txs;
>> > -	struct xen_netif_rx_sring *rxs;
>> > -
>> > -	int err = -ENOMEM;
>> > +	struct gnttab_map_grant_ref op[NETBK_MAX_RING_PAGES];
>> > +	unsigned int i;
>> > +	int err = 0;
>> >  
>> > -	err = xenbus_map_ring_valloc(xenvif_to_xenbus_device(vif),
>> > -				     tx_ring_ref, &addr);
>> 
>> Any reason why you don't just extend this function (in a prerequisite
>> patch) rather than open coding a common utility function (twice) here,
>> so that other backends (blkback!) can benefit later as well.
>> 
>> Jan
>> 
> 
> I'm mainly focusing on netback stuffs, so the code is slightly coupled
> with netback -- NETBK_MAX_RING_PAGES.
> 
> To extend xenbus_map_ring_valloc and make more generic, it requires
> setting a global maximum page number limits on rings, I think it will
> require further investigation and code refactor -- which I have no time
> to attend to at the moment. :-/

Why? You can simply pass in the number of pages, there's no need
for a global maximum.

Jan
