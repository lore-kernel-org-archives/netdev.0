From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: [PATCH wireless-dev 4/6] d80211: Send Layer 2 Update frames in kernel
Date: Thu, 24 Aug 2006 08:54:05 -0700
Message-ID: <20060824155405.GC13478@instant802.com>
References: <20060824053930.GB6104@jm.kir.nu> <20060824134316.5f5a0746@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jouni Malinen <jkmaline@cc.hut.fi>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-55.dex002.intermedia.net ([64.78.21.160]:4275 "EHLO
	dhost002-55.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751599AbWHXPyN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 11:54:13 -0400
To: Jiri Benc <jbenc@suse.cz>
Content-Disposition: inline
In-Reply-To: <20060824134316.5f5a0746@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 24, 2006 at 01:43:16PM +0200, Jiri Benc wrote:
> On Wed, 23 Aug 2006 22:39:30 -0700, Jouni Malinen wrote:
> > Which part do you think is hackish here? Sending the layer 2 update
> > frame or moving it to kernel?
> 
> The latter.
> 
> Is it really needed to send it unconditionally for each added STA? And
> cannot it be generated in userspace?

Yes, it must be sent out whenever a STA associates with the AP, i.e.,
for every STA and for every association.. This is needed to update both
the internal bridge tables in the AP and the external bridge tables in
switches etc. connected to the same physical net in order to make sure
that future frames to the STA's MAC address are delivered to the correct
AP--and within that AP, to the correct port.

This was originally done in hostapd in userspace, but this showed a bug
in which the local bridge tables did not get updated correctly in some
specific configurations. In addition, doing this in hostapd would
require that hostapd knows (or can learn) how the bridge configuration
is done on the device and this information is not really needed for
anything else, so there would not really be much point in keeping that
functionality in hostapd.

The simplest solution for this seems to be to allow the layer 2 update
frame to be sent through the exact same path as any data frame from the
STA would be coming. This makes sure that it goes through the local
bridge in the same way as other frames from the STA would go and it will
also be sent out to correct external (wired/WDS) ports automatically
based on bridge configuration.

-- 
Jouni Malinen                                            PGP id EFC895FA
