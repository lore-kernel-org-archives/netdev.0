From: Jagan Teki <jagannadh.teki@gmail.com>
Subject: Re: sblk->status_tag on drivers/net/ethernet/broadcom/tg3.c
Date: Wed, 5 Mar 2014 11:43:26 +0530
Message-ID: <CAD6G_RR=y+myvtEpa3YKiOx_8LR=Ad_nHUxuaXKakfKKyjuEaw@mail.gmail.com>
References: <CAD6G_RQVD7=v7b6S-muiZBYV7PEykTHOTM23i-BL=wcA5z=4Qg@mail.gmail.com>
	<CAD6G_RQ130TunwZDL+8vwx__8NsfzE0AfcfnS7z5OXtZF5T8xQ@mail.gmail.com>
	<1393975344.4632.10.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<CAD6G_RTVVb2qdU43PqKm3BAD2-pvVcs_O=Wck2SCBhRRV-d+Lw@mail.gmail.com>
	<1393992738.4632.15.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1393992738.4632.15.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Michael,

Thanks for your inputs.

On Wed, Mar 5, 2014 at 9:42 AM, Michael Chan <mchan@broadcom.com> wrote:
> On Wed, 2014-03-05 at 09:33 +0530, Jagan Teki wrote:
>> The driver is not seeing the status block mean - tg3.c driver?
>
> Yes, tg3 driver.  All IRQ events (link change, rx, tx) are in status
> block.  If tg3 does not see the correct bits and indexes in the status
> block, it won't know what to do.  In this case, it doesn't see the link
> change bit in status block (I suspect), so it is not acknowledging and
> clearing the link change event.  Status block is DMA'ed from the NIC to
> memory.

OK.

As per your point I've a question here like - the status block is not properly
updated (DMA'ed), does this depends on the address range we are advertised
on PCIe ranges filed to make sure to use EP-
http://devicetree.org/Device_Tree_Usage#PCI_Host_Bridge

The reason for asking this is we have two kind of PCIe bridge in separate
boards where one is working fine by showing below log, and other
we could see this issue.

# ifconfig eth0 172.16.0.2 up
RC: handler
tg3_interrupt_tagged: ++status_tag = 0x1 write status = 0x1
--status_tag = 0x1
RC: handler
tg3_interrupt_tagged: ++status_tag = 0x1 write status = 0x1
--status_tag = 0x1 tg3_poll: tag = 0x1 calling tg3_int_reenable val =
0x01000000

>
>> Does it relates to ISR or addressing of PCIe RC driver, I'm doing
>> nothing on my PCIe RC driver just read the legacy INT# status and
>> return.
>
> RC stands for what?  Root Complex?  I don't know what an RC driver does.

Yes, Root Complex driver in PCIe bridge.

-- 
Jagan.
