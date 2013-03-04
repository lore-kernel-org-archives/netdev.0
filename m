From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 0/5] net: low latency Ethernet device polling
Date: Mon, 4 Mar 2013 22:34:29 +0000
Message-ID: <1362436469.2956.33.camel@bwh-desktop.uk.solarflarecom.com>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
	 <20130227101354.15636ba5@nehalam.linuxnetplumber.net>
	 <CA+mtBx85G3qD2_QP709kOMERP9T8v1W+ZNj12qnZWg_kALQtLg@mail.gmail.com>
	 <512E5BBD.2040803@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	Dave Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	<e1000-devel@lists.sourceforge.net>,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <512E5BBD.2040803@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-02-27 at 21:17 +0200, Eliezer Tamir wrote:
> On 27/02/2013 20:47, Tom Herbert wrote:
> > On Wed, Feb 27, 2013 at 10:13 AM, Stephen Hemminger
> > <stephen@networkplumber.org> wrote:
> >>
> >> Have you looked at netmap? Seems like a cleaner user API for this.
> >>
> > That might be a bit orthogonal to this.  I believe the intent it to
> > allow spin polling from socket calls without API change.
> 
> Exactly.
> 
> BTW, an interesting alternative to netmap would be to map a VF into 
> userspace. (you would need to pre-allocate DMA memory regions and all of 
> that RDMA-like stuff)

Unless the hardware has separate event rings for completions, userland
is presumably going to need to be able to rewrite the DMA descriptor
rings.  At which point you have to restrict the VF's DMA with an IOMMU,
and might as well let userland allocate and assign DMA buffers
dynamically.

(In OpenOnload this is called 'scalable buffer mode' as an IOMMU allows
mapping more buffers than the on-board buffer table on the SFC9000
family.  The catch is that an IOMMU has higher latency.)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
