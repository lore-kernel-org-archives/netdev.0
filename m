From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 2/4]: powerpc/cell spidernet low watermark patch.
Date: Thu, 17 Aug 2006 01:43:40 +0200
Message-ID: <1155771820.11312.116.camel@localhost.localdomain>
References: <20060811170337.GH10638@austin.ibm.com>
	<20060811170813.GJ10638@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	James K Lewis <jklewis@us.ibm.com>, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: Linas Vepstas <linas@austin.ibm.com>
In-Reply-To: <20060811170813.GJ10638@austin.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-08-11 at 12:08 -0500, Linas Vepstas wrote:
> 
> Implement basic low-watermark support for the transmit queue.
> 
> The basic idea of a low-watermark interrupt is as follows.
> The device driver queues up a bunch of packets for the hardware
> to transmit, and then kicks he hardware to get it started.
> As the hardware drains the queue of pending, untransmitted 
> packets, the device driver will want to know when the queue
> is almost empty, so that it can queue some more packets.
> 
> This is accomplished by setting the DESCR_TXDESFLG flag in
> one of the packets. When the hardware sees this flag, it will 
> interrupt the device driver. Because this flag is on a fixed
> packet, rather than at  fixed location in the queue, the
> code below needs to move the flag as more packets are
> queued up. This implementation attempts to keep te flag 
> at about 3/4's of the way into the queue.
> 
> This patch boosts driver performance from about 
> 300-400Mbps for 1500 byte packets, to about 710-740Mbps.

Sounds good (without actually looking at the code though :), that was a
long required improvement to that driver. Also, we should probably look
into using NAPI polling for tx completion queue as well, no ?

Cheers,
Ben.
