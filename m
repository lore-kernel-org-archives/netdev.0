From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv2 net 2/2] sfc: Reduce RX scatter buffer size, and
 reduce alignment if appropriate
Date: Tue, 23 Jul 2013 21:19:32 +0100
Message-ID: <1374610772.2072.22.camel@bwh-desktop.uk.level5networks.com>
References: <1368482311.3305.48.camel@bwh-desktop.uk.solarflarecom.com>
	 <1368482482.3305.50.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	<linux-net-drivers@solarflare.com>,
	"Linux Kernel Development" <linux-kernel@vger.kernel.org>,
	<linux-s390@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1368482482.3305.50.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-05-13 at 23:01 +0100, Ben Hutchings wrote:
[...]
> This still doesn't fix the s390 build because like most architectures
> it has NET_IP_ALIGN == 2.  When NET_IP_ALIGN != 0 we cannot achieve
> cache line alignment at either the start or end of a scatter buffer,
> so there is actually no point in padding the buffers to a multiple of
> the cache line size.  All we need is 4-byte alignment of the network
> header, so do that.
[...]

I was just thinking about this again.  Do we need to care about
alignment in a page fragment at all?  Won't all the headers be pulled
into the header area before being accessed with any instructions that
would require alignment?  (We aren't using build_skb().)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
