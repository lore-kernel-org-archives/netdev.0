From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH] ucc_geth: Rework the TX logic.
Date: Tue, 31 Mar 2009 09:37:48 -0500
Message-ID: <49D22ABC.5050408@freescale.com>
References: <1238089445-28396-1-git-send-email-Joakim.Tjernlund@transmode.se>	<2a27d3730903270245k6e8633eehfb5cd3fcebd36240@mail.gmail.com>
	<OFDCE90357.0EDC5DC1-ONC1257586.003759A3-C1257586.00390AD3@transmode.se>
	<49CCD3E8.9040007@freescale.com>
	<OFEFCEAFB5.CC21FFBB-ONC1257589.005AEF16-C1257589.005B64EB@transmode.se>
	<49D0FFBB.7000009@freescale.com>
	<OF3127420C.081D4097-ONC1257589.00603E3D-C1257589.006093B3@transmode.se>
	<49D1052D.2050609@freescale.com>
	<OF70832E04.3DC53F05-ONC1257589.00663AFF-C1257589.0066C397@transmode.se>
	<49D11E47.8080106@freescale.com>
	<OFEAA9D1E3.4B2F3270-ONC125758A.00307236-C125758A.00322239@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Li Yang <leoli@freescale.com>, pku.leo@gmail.com,
	netdev@vger.kernel.org
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <OFEAA9D1E3.4B2F3270-ONC125758A.00307236-C125758A.00322239@transmode.se>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Joakim Tjernlund wrote:
> I am a bit confused, what isn't worth it?

Enabling cacheing on MURAM, at least when used for buffer descriptors. 
The cache line ping-pong would probably outweigh the cost of the 
uncached accesses.

> Currently MURAM isn't used by ucc_geth,

Hmm.  I looked in the driver and saw numerous muram allocations, but I 
didn't try to follow the driver enough to ensure that they were for the 
ring.  I'd assumed it was similar to the CPM1/CPM2 driver.

> 3) as gianfar, dma_alloc_coherent(). I presume this is uncacheable memory?

It would be uncacheable on systems without coherent DMA, but I don't 
think there are any such systems that use gianfar.

> My guess would be 2 or 3. Do they have the same synchronization
> sematics?

No, unfortunately.  PowerPC sync instructions are a bit complicated. 
For example, you can use eieio to sync between reading the interrupt 
status register and checking the ring buffer, if they're both mapped 
I+G, but not if the former is I+G and the latter is cacheable (you need 
a full sync in that case).

-Scott
