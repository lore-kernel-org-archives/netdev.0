From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] XFRM: SPD auditing fix to include the netmask/prefix-length
Date: Thu, 29 Nov 2007 08:45:46 -0500
Message-ID: <200711290845.46623.paul.moore@hp.com>
References: <20071126195512.6176.10448.stgit@flek.americas.hpqcorp.net> <20071129103459.GD22537@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com,
	Joy Latten <latten@us.ibm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:49839 "EHLO mailhub.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754610AbXK2Nqj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2007 08:46:39 -0500
In-Reply-To: <20071129103459.GD22537@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 29 November 2007 5:34:59 am Herbert Xu wrote:
> On Mon, Nov 26, 2007 at 07:55:12PM +0000, Paul Moore wrote:
> > Currently the netmask/prefix-length of an IPsec SPD entry is not included
> > in any of the SPD related audit messages.  This can cause a problem when
> > the audit log is examined as the netmask/prefix-length is vital in
> > determining what network traffic is affected by a particular SPD entry. 
> > This patch fixes this problem by adding two additional fields,
> > "src_prefixlen" and "dst_prefixlen", to the SPD audit messages to
> > indicate the source and destination netmasks.  These new fields are only
> > included in the audit message when the netmask/prefix-length is less than
> > the address length, i.e. the SPD entry applies to a network address and
> > not a host address.
>
> Any reason why we don't just always include them?

The audit folks seem to be very sensitive to the size/length of the audit 
messages, they prefer they be as small as possible.  I thought that one way 
to save space would be to only print the prefix length information when the 
address referred to a network and not a single host.

Would you prefer it if the prefix length information was always included in 
the audit message?  Joy?  Audit folks?

-- 
paul moore
linux security @ hp
