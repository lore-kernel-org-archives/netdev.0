From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 1/1] net/macb: add TX multiqueue support for gem
Date: Fri, 12 Dec 2014 09:45:30 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CA0BA36@AcuExch.aculab.com>
References: <cover.1418291637.git.cyrille.pitchen@atmel.com>
	<87a3098203ee6eaa7a60607713a293d3258e2b58.1418291637.git.cyrille.pitchen@atmel.com>
 <20141211203103.4191887a@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"soren.brinkmann@xilinx.com" <soren.brinkmann@xilinx.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Thomas Petazzoni' <thomas.petazzoni@free-electrons.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141211203103.4191887a@free-electrons.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Petazzoni
> On Thu, 11 Dec 2014 11:16:51 +0100, Cyrille Pitchen wrote:
> 
> > +#define GEM_ISR1				0x0400
> > +#define GEM_ISR2				0x0404
> > +#define GEM_ISR3				0x0408
> > +#define GEM_ISR4				0x040c
> > +#define GEM_ISR5				0x0410
> > +#define GEM_ISR6				0x0414
> > +#define GEM_ISR7				0x0418
> 
> What about doing instead:
> 
> #define GEM_ISR(q)				((q) == 0 ? MACB_ISR : 0x400 + (q) << 2)
> 
> And ditto for all other registers, which will save a lot of boring repeated code.

It will probably add a lot of object code and, depending on how often
the registers are accesses, might have performance impact.

Having:
#define GEM_ISR(n) (0x400 + (n) << 4)
will save source code.

	David
