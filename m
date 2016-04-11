From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [Lsf] [Lsf-pc] [LSF/MM TOPIC] Generic page-pool recycle
 facility?
Date: Mon, 11 Apr 2016 20:37:38 +0200
Message-ID: <20160411203738.58a6adb2@redhat.com>
References: <1460034425.20949.7.camel@HansenPartnership.com>
	<20160407161715.52635cac@redhat.com>
	<20160411085819.GE21128@suse.de>
	<20160411142639.1c5e520b@redhat.com>
	<20160411130826.GB32073@techsingularity.net>
	<20160411162047.GJ2781@linux.intel.com>
	<20160411174625.GH1845@indiana.gru.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Matthew Wilcox <willy@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Brenden Blanco <bblanco@plumgrid.com>,
	lsf@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>,
	Mel Gorman <mgorman@suse.de>,
	Tom Herbert <tom@herbertland.com>,
	lsf-pc@lists.linux-foundation.org,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	brouer@redhat.com
To: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43975 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751623AbcDKShu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2016 14:37:50 -0400
In-Reply-To: <20160411174625.GH1845@indiana.gru.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 11 Apr 2016 14:46:25 -0300
Thadeu Lima de Souza Cascardo <cascardo@redhat.com> wrote:

> So, Jesper, please take into consideration that this pool design
> would rather be per device. Otherwise, we allow some device to write
> into another's device/driver memory.

Yes, that was my intended use.  I want to have a page-pool per device.
I actually, want to go as far as a page-pool per NIC HW RX-ring queue.

Because the other use-case for the page-pool is zero-copy RX.

The NIC HW trick is that we today can create a HW filter in the NIC
(via ethtool) and place that traffic into a separate RX queue in the
NIC.  Lets say matching NFS traffic or guest traffic. Then we can allow
RX zero-copy of these pages, into the application/guest, somehow
binding it to RX queue, e.g. introducing a "cross-domain-id" in the
page-pool page that need to match.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
