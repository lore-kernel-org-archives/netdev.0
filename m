From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] xen-netfront sets partial checksum at wrong offset
Date: Fri, 29 May 2015 11:39:16 +0100
Message-ID: <20150529103916.GY30474@zion.uk.xensource.com>
References: <ee74926e-deb3-4cbc-9798-42c19f4fe219@default>
 <20150511150827.GA23561@l.oracle.com>
 <3a08e270-3a70-417b-9ab8-439c7cdc1eb2@default>
 <55685CBF020000780007EEF8@mail.emea.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Venkat Venkatsubra <venkat.x.venkatsubra@oracle.com>,
	<david.vrabel@citrix.com>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Konrad Wilk <konrad.wilk@oracle.com>, <netdev@vger.kernel.org>
To: Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:21936 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753839AbbE2KjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 06:39:19 -0400
Content-Disposition: inline
In-Reply-To: <55685CBF020000780007EEF8@mail.emea.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2015 at 11:34:07AM +0100, Jan Beulich wrote:
> >>> On 11.05.15 at 19:25, <venkat.x.venkatsubra@oracle.com> wrote:
> >>  
> >> Please CC the maintainers of the driver. You can get that from
> >> 'scripts/get_maintainer.pl'
> >> 
> >> I've done that for you.
> > 
> > Thanks, Konrad.
> > 
> > I am copying Wei too who had fixed the below problem earlier.
> > It fixed the incorrect ip_hdr(). tcp_hdr() still needs to fixed.
> > 
> > commit d554f73df6bc35ac8f6a65e5560bf1d31dfebed9
> > Author: Wei Liu <wei.liu2@citrix.com>
> > Date:   Wed Feb 19 18:48:34 2014 +0000
> > 
> >     xen-netfront: reset skb network header before checksum
> 
> So no response at all so far from the maintainers made me look into
> this: I first thought what we need would be calls to
> skb_probe_transport_header() in skb_checksum_setup_ip() after
> each of the skb_maybe_pull_tail() functions. But
> skb_partial_csum_set() already calls skb_set_transport_header(),
> so I now think things ought to be fine without any change. Can
> you clarify what you think is missing? Or is this an issue in just the
> old (3.8.x) kernel you're using?
> 

I think this is the follow-up thread <20150512013424.GA7960@oracle.com>

And the conclusion is 3.8 is too old so the fix is not there.

> (In either case netback's xenvif_tx_submit() calling
> skb_probe_transport_header() would seem pointless, as
> skb_checksum_setup() - with or without a fix - ought to be taking
> care of this anyway.)
> 

Patches welcome. :-)

Wei.

> Jan
