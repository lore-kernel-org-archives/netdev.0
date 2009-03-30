From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: [PATCH] ucc_geth: Rework the TX logic.
Date: Mon, 30 Mar 2009 20:42:28 +0200
Message-ID: <OF70832E04.3DC53F05-ONC1257589.00663AFF-C1257589.0066C397@transmode.se>
References: <1238089445-28396-1-git-send-email-Joakim.Tjernlund@transmode.se>	<2a27d3730903270245k6e8633eehfb5cd3fcebd36240@mail.gmail.com>
	<OFDCE90357.0EDC5DC1-ONC1257586.003759A3-C1257586.00390AD3@transmode.se>
	<49CCD3E8.9040007@freescale.com>
	<OFEFCEAFB5.CC21FFBB-ONC1257589.005AEF16-C1257589.005B64EB@transmode.se>
	<49D0FFBB.7000009@freescale.com>
	<OF3127420C.081D4097-ONC1257589.00603E3D-C1257589.006093B3@transmode.se>
	<49D1052D.2050609@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, Li Yang <leoli@freescale.com>, pku.leo@gmail.com,
	netdev@vger.kernel.org
To: Scott Wood <scottwood@freescale.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
In-Reply-To: <49D1052D.2050609@freescale.com>
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

Scott Wood <scottwood@freescale.com> wrote on 30/03/2009 19:45:17:
> 
> Joakim Tjernlund wrote:
> > Scott Wood <scottwood@freescale.com> wrote on 30/03/2009 19:22:03:
> >> Joakim Tjernlund wrote:
> >>> gianfar does not seem to use in_/out_ functions for the BDs. Works 
> > just
> >>> fine that too it seems.
> >> It does now that it has explicit barriers in a few places.  Before 
they
> > 
> > In 2.6.29 or later?
> 
> No, it was earlier.

Ah, I see now. The eieio() stuff.

> 
> >> were added, it would sometimes fail under load.  That was due to a 
> >> compiler reordering, but CPU reordering was possible as well.
> > 
> > Does not the CPU skip reordering if the guarded bit is set?
> 
> The guarded bit is typically not set for DMA buffers.  ucc_geth is a bit 

> different since descriptors are in MURAM which is ioremap()ed -- though 
> switching to a cacheable mapping with barriers should be a performance 
> improvement.

I always thought that MURAM was very fast. The whole reason to have BDs in
MURAM is that it is faster than normal RAM, at least that is what I 
thought.

 Jocke
