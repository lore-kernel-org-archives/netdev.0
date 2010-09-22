From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [PATCH 2/2] siw: Add support for CRC32C offload instruction
	using libcrypto crc32c-intel
Date: Wed, 22 Sep 2010 15:36:29 -0700
Message-ID: <1285194989.1849.130.camel@haakon2.linux-iscsi.org>
References: <1285187425-10950-1-git-send-email-nab@linux-iscsi.org>
	 <4C9A698B.90806@linux.intel.com>
	 <1285187901.1849.85.camel@haakon2.linux-iscsi.org>
	 <20100922205943.GI11157@obsidianresearch.com>
	 <1285189241.1849.112.camel@haakon2.linux-iscsi.org>
	 <20100922211808.GJ11157@obsidianresearch.com>
	 <1285191511.1849.126.camel@haakon2.linux-iscsi.org>
	 <20100922220611.GL11157@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Bernard Metzler <BMT@zurich.ibm.com>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100922220611.GL11157@obsidianresearch.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-09-22 at 16:06 -0600, Jason Gunthorpe wrote:
> On Wed, Sep 22, 2010 at 02:38:31PM -0700, Nicholas A. Bellinger wrote:
> 
> > So I think the main bit here is the ability to request
> > crc32c-intel.ko first, and then fall back to crc32c.ko when the
> > former is not available on CONFIG_X86.
> 
> Well, it is what Andi said, everything is working fine but there is no
> mechanism to autoload the accelerated crypto module. If you did
> modprobe crc32c_intel prior to loading your driver it would
> automatically get crc32c-intel when it asks for crc32c since it is
> loaded and a higher priority.
> 

Ah, OK.  I see what you mean now here wrt to libcrypto priorities and
crc32c + crc32c_intel modules.   My apologies for the in-experience with
libcrypto here..

> So, the drivers are correct to just request crc32c .. The work around
> to limited autoprobing is so trivial (modprob crc32_intel) I'm not
> sure including extra autoprobing code in the drivers is worthwhile?
> 

Indeed, I am happy to drop this patch if Bernard would be nice enough to
add a 'modprobe crc32_intel' into the SIW scripts.

Thanks for your comments Jason!

--nab
