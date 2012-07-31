From: Jon Mason <jon.mason@intel.com>
Subject: Re: [RFC v2 1/2] PCI-Express Non-Transparent Bridge Support
Date: Tue, 31 Jul 2012 09:33:08 -0700
Message-ID: <20120731163308.GA13610@jonmason-lab>
References: <1343607994-32415-1-git-send-email-jon.mason@intel.com>
 <1343607994-32415-2-git-send-email-jon.mason@intel.com>
 <CAErSpo4p_hxvCeVGqiTXVq3itXepheQZerpqRHwLvG6A7R2Lcg@mail.gmail.com>
 <20120730181542.GA987@jonmason-lab>
 <CAF8raN6M0_TWyCCzjyXZcFYP=vgFaqQg4hNmNpBxSM+D0C_Bpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bjorn Helgaas <bhelgaas@google.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	Dave Jiang <dave.jiang@intel.com>
To: Jianbin Kang <kjbmail@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAF8raN6M0_TWyCCzjyXZcFYP=vgFaqQg4hNmNpBxSM+D0C_Bpg@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 31, 2012 at 11:35:33AM +0800, Jianbin Kang wrote:
> > I've tried to make it all generic enough that non-Intel NTBs should plug in with
> > minimal changes to ntb_hw.c.  If their design is too divergent, then a slight
> > redesign of ntb_hw.c might be necessary.  But from what I've seen of other
> > designs on the internet, they appear to be extremely similar.  The transport and
> > client drivers were written with the hardware abstracted away as much as
> > possible to prevent the need to modify it for different hardware.  If there is
> > anything which is Intel hardware specific, I'd be happy to change it to make it
> > more generic.
>   In ntb_process_tx(), ntb uses hard-coding 'memcpy_toio' to copy data
> to remote.
>   Is it better to provide a function pointer like 'tx()' and call qp->tx().
>   memcpy_toio is a slow operation. Some hardware can setup a dma
> transfer and wait.
> 
>   IMHO, the best way is to handle tx in async mode. But it requires
> lots of modification.

Actually this is what I'm working on now, using async_tx to replace the
memcpy.  I believe the changes shouldn't be that significant.

Is the "hardware that can setup dma" you refer to something that does
not use this interface?

Thanks,
Jon
