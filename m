From: William Dauchy <wdauchy@gmail.com>
Subject: Re: [Xen-devel] xen-netback stable backports request (regression fixes)
Date: Fri, 31 May 2013 15:20:34 +0200
Message-ID: <CAJ75kXbyqa=HJD7x9OoGTh99YoiUJz8ioEdMwh5Ryko5daev-g@mail.gmail.com>
References: <1369734465.3469.52.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: stable@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org, Wei Liu <wei.liu2@citrix.com>,
	xen-devel <xen-devel@lists.xen.org>,
	Luis Henriques <luis.henriques@canonical.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f176.google.com ([209.85.128.176]:65033 "EHLO
	mail-ve0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752094Ab3EaNUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 09:20:55 -0400
In-Reply-To: <1369734465.3469.52.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Ian,

On Tue, May 28, 2013 at 11:47 AM, Ian Campbell <Ian.Campbell@citrix.com> wrote:
> The following set of patches fix a xen netback regression caused by the
> fixes for CVE-2013-0216 / CVE-2013-0217 / XSA-39 (the original change
> was several patches starting at 48856286b64e), we'd like to see them
> backported to stable branches if possible. I think the fixups have now
> been in Linus tree since around the start of May.
>
> Wei and I are happy to help with backports if necessary. Some of the
> patches are cleanups which make backports easier but if you would prefer
> we could produce backports without them.
>
> 27f85228 xen-netback: remove skb in xen_netbk_alloc_page
> 2810e5b9 xen-netback: coalesce slots in TX path and fix regressions
> 03393fd5 xen-netback: don't disconnect frontend when seeing oversize packet
> ac69c26e xen-netback: remove redundent parameter in netbk_count_requests
> 59ccb4eb xen-netback: avoid allocating variable size array on stack
> 37641494 xen-netback: better names for thresholds
>
> In addition there are some useful related (but not security relevant)
> fixes to netfront:
>
> e2d617c0 xen-netfront: remove unused variable `extra'
> 7158ff6d xen-netfront: frags -> slots in xennet_get_responses
> 697089dc xen-netfront: frags -> slots in log message
> 9ecd1a75 xen-netfront: reduce gso_max_size to account for max TCP header

I applied the patches on a 3.4.x kernel.
for netback I had to include:
9eaee8b xen-netback: fix sparse warning
which I guess is ok to include in 3.4

for netfront, as Luis said, I also add to include:
f36c374 xen/netfront: handle compound page fragments on transmit
which is not a simple patch.

Regards,
--
William
