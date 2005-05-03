From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Mystery packet killing tg3
Date: Tue, 3 May 2005 15:45:00 -0700
Message-ID: <20050503154500.0a53160d@dxpl.pdx.osdl.net>
References: <20050502162405.65dfb4a9@localhost.localdomain>
	<20050502200251.38271b61.davem@davemloft.net>
	<20050503140528.1bd2ac74@dxpl.pdx.osdl.net>
	<20050503141314.441c9d75.davem@davemloft.net>
	<1115152907.15156.26.camel@rh4>
	<20050503150333.1ac1c159.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Michael Chan" <mchan@broadcom.com>, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050503150333.1ac1c159.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 3 May 2005 15:03:33 -0700
"David S. Miller" <davem@davemloft.net> wrote:

> On Tue, 03 May 2005 13:41:47 -0700
> "Michael Chan" <mchan@broadcom.com> wrote:
> 
> > MSI is buggy on 5703 and tg3 will not enable MSI on that chip. MSI only
> > works on the latest PCI Express chips.
> 
> Ok, and he has a pre-MSI copy of the tg3 driver anyways.
> 
> Michael, there were no master/target abort bits set in the PCI status
> register from his dump.  If one of the DMA units locks up on the tg3,
> will it still be able to update the PCI_STATUS register appropriately
> when it encounters a DMA transaction error (ie. master or target abort)
> or would we also need to look at the PCI host bridge PCI config space
> registers as well?
> 
> I strongly suspect one of two things in these AMD system cases of tg3
> wedging:
> 
> 1) some DMA problem
> 2) register write reordering
> 
> Lack of master/target abort indication in tg3's PCI status register
> makes me feel that #2 is more likely to be the problem cause.
> 
> Just for fun, Stephen, can you make tg3_get_invariants() always set
> the TG3_FLAG_MBOX_WRITE_REORDER bit in tp->tg3_flags and see if that
> makes the problem go away?

No, I forced it to always be true and still dies (when taking network down).
