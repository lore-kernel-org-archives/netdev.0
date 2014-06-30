From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Sporadic ESP payload corruption when using IPSec in NAT-T
 Transport Mode
Date: Mon, 30 Jun 2014 21:21:19 +0800
Message-ID: <20140630132119.GA19500@gondor.apana.org.au>
References: <CALEwOppxvZ5F1-HeEnEEfe+GXs4=q+Eq+yL6W4xshemW8Wu9Ww@mail.gmail.com>
 <20140630113324.GR32371@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evan Gilman <evan@pagerduty.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:49228 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033AbaF3NVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 09:21:30 -0400
Content-Disposition: inline
In-Reply-To: <20140630113324.GR32371@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 30, 2014 at 01:33:24PM +0200, Steffen Klassert wrote:
> Ccing netdev.
> 
> On Thu, Jun 26, 2014 at 02:12:30PM -0700, Evan Gilman wrote:
> >    Hi all
> >    We have a couple Ubuntu 10.04 hosts with kernel version 3.14.5 which are
> >    experiencing TCP payload corruption when using IPSec in NAT-T transport
> >    mode. All are running under Xen at third party providers. When
> >    communicating with other hosts using IPSec, we see that these corrupt TCP
> >    PDUs are still being received by the remote listener, even though the TCP
> >    checksum is invalid.
> >    All other checksums (IPSec authentication header and IP checksum) are
> >    good. So, we are thinking that corruption is happening during the ESP
> >    encapsulation and decapsulation phase (IPSec required for reproduction).
> >    The corruption occurs sporadically, and we have not found any one
> >    payload/packet combination that will reliably trigger it, though we can
> >    typically reproduce it in less than 30 minutes. We can do it very simply
> >    by reading from /dev/zero with dd and piping through netcat. It occurs
> >    whenever a 3.14.5 kernel is involved at either end of the conversation. I
> >    can send captures to those who are interested. Does any of this sound
> >    familiar?
> 
> I can't remember anyone reporting such problems, but maybe someone
> else does.

I have seen one report where a Xen guest experienced IPsec corruption
when using aesni-intel.  However, in that case the corruption was at
the authentication level.  Are you using aesni-intel by any chance?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
