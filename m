From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: bnx2 dirver's firmware images
Date: Wed, 19 Sep 2007 21:29:22 +0100
Message-ID: <200709192129.23034.vda.linux@googlemail.com>
References: <200709181823.26429.vda.linux@googlemail.com> <200709190930.39882.vda.linux@googlemail.com> <1190235642.9540.261.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	"netdev" <netdev@vger.kernel.org>
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756915AbXISU3q@vger.kernel.org>
In-Reply-To: <1190235642.9540.261.camel@dell>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 19 September 2007 22:00, Michael Chan wrote:
> On Wed, 2007-09-19 at 09:30 +0100, Denys Vlasenko wrote:
> +       /* gzip header (1f,8b,08... 10 bytes total + possible asciz filename)
> +        * is stripped, 32-bit unpacked size (LE) is prepended instead */
> +       sz = *zbuf++;
> +       sz = (sz << 8) + *zbuf++;
> +       sz = (sz << 8) + *zbuf++;
> +       sz = (sz << 8) + *zbuf++;
> 
> I don't have a problem with removing the gzip header.  It doesn't
> contain very useful information other than a valid header for sanity
> check.  But I don't think we need to arbitrarily add the unpacked size
> in front of the gzipped data.  The driver knows the size (e.g. the size
> of RAM on the chip) and should pass it to the call.  The driver should
> also allocate the memory for the unpacked data instead of allocating the
> memory inside the call and freeing it by the caller.  For example, the
> driver may need to use pci_alloc_consistent() if the firmware is to be
> DMA'ed to the chip.
> 
> Other than that, everything else looks fine.  Thanks.

Are you saying that you successfully run-tested it?
--
vda
