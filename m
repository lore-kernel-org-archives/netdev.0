From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 support broken on PPC, a workaround
Date: Wed, 11 May 2005 08:24:41 -0700
Message-ID: <1115825081.8570.93.camel@rh4>
References: <20050510113308.kbjo3ob1ck0404k8@158.49.151.11>
 <1115743966.8570.26.camel@rh4>
 <20050511080446.fnstrvtzq8gk8884@158.49.151.11>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Manuel Perez Ayala" <mperaya@alcazaba.unex.es>
In-Reply-To: <20050511080446.fnstrvtzq8gk8884@158.49.151.11>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-05-11 at 08:04 +0200, Manuel Perez Ayala wrote:

> Working driver:
> 
> On init of driver:
> 
> tg3.c:v3.10 (September 14, 2004)
> PCI: Enabling device 0001:10:13.0 (0014 -> 0016)
> 
> tg3: tg3_test_dma #1: 76FF120F
> 

This tells me that your cache line size is 32 bytes.

Let's try some experiments and see what works and what doesn't. Please
hardcode the following values in tp->dma_rwctrl before it is written to
the register:

1. DMA read/write boundaries set to 256:

tp->dma_rwctrl = 0x76ff2d0f;

2. DMA read boundary 256, write boundary 32:

tp->dma_rwctrl = 0x76ff150f;

3. DMA read boundary 32, write boundary 256

tp->dma_rwctrl = 0x76ff2a0f;

4. Let's also try without asserting all byte enables:

tp->dma_rwctrl = 0x763f2d0f;

Thanks.
