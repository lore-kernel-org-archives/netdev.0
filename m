From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH net-next] xen-netfront: convert to GRO API
 and advertise this feature
Date: Sun, 22 Sep 2013 13:09:36 +0100
Message-ID: <20130922120936.GA4079@zion.uk.xensource.com>
References: <1379779543-27122-1-git-send-email-wei.liu2@citrix.com>
 <523E8E3B.3050805@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>,
	Anirban Chakraborty <abchak@juniper.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	<xen-devel@lists.xen.org>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:45455 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752897Ab3IVMJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Sep 2013 08:09:38 -0400
Content-Disposition: inline
In-Reply-To: <523E8E3B.3050805@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 22, 2013 at 02:29:15PM +0800, Jason Wang wrote:
> On 09/22/2013 12:05 AM, Wei Liu wrote:
> > Anirban was seeing netfront received MTU size packets, which downgraded
> > throughput. The following patch makes netfront use GRO API which
> > improves throughput for that case.
> >
> > Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> > Signed-off-by: Anirban Chakraborty <abchak@juniper.net>
> > Cc: Ian Campbell <ian.campbell@citrix.com>
> 
> Maybe a dumb question: doesn't Xen depends on the driver of host card to
> do GRO and pass it to netfront? What the case that netfront can receive

The would be the ideal situation. Netback pushes large packets to
netfront and netfront sees large packets.

> a MTU size packet, for a card that does not support GRO in host? Doing

However Anirban saw the case when backend interface receives large
packets but netfront sees MTU size packets, so my thought is there is
certain configuration that leads to this issue. As we cannot tell
users what to enable and what not to enable so I would like to solve
this within our driver.

> GRO twice may introduce extra overheads.
> 

AIUI if the packet that frontend sees is large already then the GRO path
is quite short which will not introduce heavy penalty, while on the
other hand if packet is segmented doing GRO improves throughput.

Wei.

> Thanks
