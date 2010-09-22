From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [PATCH 2/2] siw: Add support for CRC32C offload instruction
	using libcrypto crc32c-intel
Date: Wed, 22 Sep 2010 14:00:41 -0700
Message-ID: <1285189241.1849.112.camel@haakon2.linux-iscsi.org>
References: <1285187425-10950-1-git-send-email-nab@linux-iscsi.org>
	 <4C9A698B.90806@linux.intel.com>
	 <1285187901.1849.85.camel@haakon2.linux-iscsi.org>
	 <20100922205943.GI11157@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@linux.intel.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Bernard Metzler <BMT@zurich.ibm.com>,
	David Miller <davem@davemloft.net>,
	Matthew Wilcox <willy@linux.intel.com>,
	Roland Dreier <rdreier@cisco.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100922205943.GI11157@obsidianresearch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-09-22 at 14:59 -0600, Jason Gunthorpe wrote:
> On Wed, Sep 22, 2010 at 01:38:21PM -0700, Nicholas A. Bellinger wrote:
> 
> > Indeed, this would clean up the explict RX/TX CRC32C case quite a
> > bit..  Unfortuately I am too busy with other items atm to cook up
> > this patch, but I would be happy to test it if someone wants to take
> > it.  ;)
> 
> Do you even need to do anything at all? crc32c is provided by
> crc32c-intel at a higher priority already, so it should be used if it
> is available..

I believe with the current libcrypto code that consumers are still
required to explictly ask for crc32c-intel offload.

>  
> > > Need CPUID module auto probing. I have an older patch that needs
> > > some fixes.
> 
> > Hmm, I don't see how that fits in here exactly.  Would you mind
> > elaborating a bit..?
> 
> Unless the module is loaded the optimized algorithm will not be
> available for automatic use. Maybe your patch causes it to autoload
> because of the by-name reference? Identifying modules to load by CPUID
> will let userspace auto load the appropriate ones based on CPU...
> 

Correct, this patch is so that autoload of crc32c-intel.ko 'just works'
and we do the fallback to the legacy slicing by 1x crc32c.ko when the
former is not availabe.

But I definately agree with Andi here that we should just add a wrapper
around the crypto_alloc_hash() usage of crc32c-intel and crc32c for
libcrypto consumers..

Thanks for your comments Jason!

--nab
