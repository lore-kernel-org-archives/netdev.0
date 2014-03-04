From: Michael Chan <mchan@broadcom.com>
Subject: Re: sblk->status_tag on drivers/net/ethernet/broadcom/tg3.c
Date: Tue, 4 Mar 2014 15:22:23 -0800
Message-ID: <1393975344.4632.10.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <CAD6G_RQVD7=v7b6S-muiZBYV7PEykTHOTM23i-BL=wcA5z=4Qg@mail.gmail.com>
	 <CAD6G_RQ130TunwZDL+8vwx__8NsfzE0AfcfnS7z5OXtZF5T8xQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>
To: Jagan Teki <jagannadh.teki@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <CAD6G_RQ130TunwZDL+8vwx__8NsfzE0AfcfnS7z5OXtZF5T8xQ@mail.gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-03-04 at 23:25 +0530, Jagan Teki wrote: 
> From the comments in ISR any non-zero value to intr-mbox-0 clear
> the interrupt ie write status as 1 so I assume interrupt is clear and then
> in tg3_int_reenable is going to write 0x0 on to intr-mbox-0
> which again reenables the interrupt, was my guess is true?

Yes, the (last_tag << 24) is also written to the intr-mbox-0 to
acknowledge the status block.


> And sblk->status_tag is always 0 in ISR and BH(poll) why is that so?
> If it's is 1(unsigned non-zero) then possibly tg3_int_reenable will write
> non-zero value on intr-mbox-0 which will clear the interrupt.

You should print out the entire status block.  It shouldn't be zero.
The status tag should be incrementing for each interrupt.

> 
> Request for any help who updates sblk->status_tag value and
> how many time the ISR in PCIe RC and ISR in EP will call for link up?
> 
> 
If you are expecting link up, the first 32-bit word of the status block
should have bit 1 set (bit 0 should also be set).  I think the driver is
not seeing the status block correctly, so it is not acknowledging the
link change interrupt and the status_tag.
