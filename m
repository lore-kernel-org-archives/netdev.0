From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 support broken on PPC, a workaround
Date: Tue, 10 May 2005 09:52:46 -0700
Message-ID: <1115743966.8570.26.camel@rh4>
References: <20050510113308.kbjo3ob1ck0404k8@158.49.151.11>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Manuel Perez Ayala" <mperaya@alcazaba.unex.es>
In-Reply-To: <20050510113308.kbjo3ob1ck0404k8@158.49.151.11>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-05-10 at 11:33 +0200, Manuel Perez Ayala wrote:

> 
> If I replace the 2.6.8 piece of code with the 2.6.7 one and compile the code, it
> seems to work without problems of data corruption.
> 
Can you print out the value of tp->dma_rwctrl in hex just before it is
written to the register in the line:

tw32(TG3PCI_DMA_RW_CTRL, tp->dma_rwctrl);

Please do this for the working and non-working driver versions.

I assume you have a 5700 or 5701 as this code that controls the DMA
boundaries only affects those devices. Please confirm with the lspci
output or tg3's probing output.

In the new code, the DMA write bursts will disconnect at multiples of
cache lines instead of 1 cache line. And DMA read bursts will not
disconnect at cache line boundaries.
