From: viro@parcelfarce.linux.theplanet.co.uk
Subject: Re: [PATCH] Fix readw/writew warnings in drivers/net/wireless/hermes.h
Date: Mon, 11 Oct 2004 14:33:02 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041011133302.GV23987@parcelfarce.linux.theplanet.co.uk>
References: <Pine.LNX.4.61.0410110702590.7899@linaeum.absolutedigital.net> <1a50bd3704101105046e66538c@mail.gmail.com> <20041011123137.GB28100@zax> <200410111518.39001.petkov@uni-muenster.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Gibson <hermes@gibson.dropbear.id.au>,
        Ricky lloyd <ricky.lloyd@gmail.com>,
        Jan Dittmer <j.dittmer@portrix.net>,
        Cal Peake <cp@absolutedigital.net>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        NetDev Mailing List <netdev@oss.sgi.com>, proski@gnu.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Borislav Petkov <petkov@uni-muenster.de>
Content-Disposition: inline
In-Reply-To: <200410111518.39001.petkov@uni-muenster.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Oct 11, 2004 at 03:18:38PM +0200, Borislav Petkov wrote:
> that in a great detail. As a result, the right thing to do here is, I think, to declare all addrs void __iomem*.
> Which leaves a question: while compiling the following code fragment:
> 
> <sound/pci/ymfpci/ymfpci_main.c>
>   static inline u8 snd_ymfpci_readb(ymfpci_t *chip, u32 offset)
>   {
>           return readb(chip->reg_area_virt + offset);
>   }
> 
> gcc complains as so:
> 
> sound/pci/ymfpci/ymfpci_main.c: In function `snd_ymfpci_readb':
> sound/pci/ymfpci/ymfpci_main.c:57: warning: passing arg 1 of `readb' makes pointer from integer without a cast
> 
> Do we have to cast here or use the new interface?

Make ->reg_area_virt void __iomem *.  *However*, ALSA folks said that they
have already done iomem annotations in their tree, so that's an area best
left alone until they merge.
