From: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Subject: Re: [PATCH 2/2] siw: Add support for CRC32C offload instruction
	using libcrypto crc32c-intel
Date: Wed, 22 Sep 2010 16:06:11 -0600
Message-ID: <20100922220611.GL11157@obsidianresearch.com>
References: <1285187425-10950-1-git-send-email-nab@linux-iscsi.org> <4C9A698B.90806@linux.intel.com> <1285187901.1849.85.camel@haakon2.linux-iscsi.org> <20100922205943.GI11157@obsidianresearch.com> <1285189241.1849.112.camel@haakon2.linux-iscsi.org> <20100922211808.GJ11157@obsidianresearch.com> <1285191511.1849.126.camel@haakon2.linux-iscsi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
To: "Nicholas A. Bellinger" <nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1285191511.1849.126.camel-Y1+j5t8j3WgjMeEPmliV8E/sVC8ogwMJ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 22, 2010 at 02:38:31PM -0700, Nicholas A. Bellinger wrote:

> So I think the main bit here is the ability to request
> crc32c-intel.ko first, and then fall back to crc32c.ko when the
> former is not available on CONFIG_X86.

Well, it is what Andi said, everything is working fine but there is no
mechanism to autoload the accelerated crypto module. If you did
modprobe crc32c_intel prior to loading your driver it would
automatically get crc32c-intel when it asks for crc32c since it is
loaded and a higher priority.

So, the drivers are correct to just request crc32c .. The work around
to limited autoprobing is so trivial (modprob crc32_intel) I'm not
sure including extra autoprobing code in the drivers is worthwhile?

Jason
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
