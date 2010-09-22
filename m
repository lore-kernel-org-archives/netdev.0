From: Andi Kleen <ak-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH 2/2] siw: Add support for CRC32C offload instruction using
 libcrypto crc32c-intel
Date: Wed, 22 Sep 2010 22:39:39 +0200
Message-ID: <4C9A698B.90806@linux.intel.com>
References: <1285187425-10950-1-git-send-email-nab@linux-iscsi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Matthew Wilcox <willy-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
To: "Nicholas A. Bellinger" <nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1285187425-10950-1-git-send-email-nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

  On 9/22/2010 10:30 PM, Nicholas A. Bellinger wrote:
> From: Nicholas Bellinger<nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org>
>
> This patch updates siw_create_qp() to check for the CONFIG_X86 + cpu_has_xmm4_2
> dependent use of the CRC32C instruction offload using libcrypto crc32c-intel.ko.
> This patch will by default use crc32c-intel when available, and fall back to the
> legacy slicing by 1x libcrypto crc32c.ko code when the instruction offload is not
> availabe.

I don't think every caller should handle checks like this. The crypto 
layer should load the right driver
instead and provide the best driver under a generic algorithm name.

Need CPUID module auto probing. I have an older patch that needs some fixes.

-Andi

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
