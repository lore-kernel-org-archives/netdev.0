From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [BUG] sundance "Something Wicked happened!" (IntrPCIErr)
Date: Mon, 31 Jan 2005 11:38:34 -0800
Message-ID: <20050131113834.440faca8.davem@davemloft.net>
References: <20050131165947.GJ6878@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20050131165947.GJ6878@sunbeam.de.gnumonks.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 31 Jan 2005 17:59:48 +0100
Harald Welte <laforge@gnumonks.org> wrote:

> Looking at the source code, the error message only happens if IntrPCIErr
> is set.  

Try adding a printout here of the PCI status register in config
space when this happens, something like:

	{
		u16 val;
		pci_read_config_word(np->pci_dev, PCI_STATUS, &val);
		printk("%s: PCI status is %x\n", dev->name, val);
	}

What we'll be looking for are bits set there such as
PCI_STATUS_SIG_TARGET_ABORT, PCI_STATUS_REC_TARGET_ABORT,
PCI_STATUS_REC_MASTER_ABORT, PCI_SIG_SYSTEM_ERROR, or
PCI_STATUS_DETECTED_PARITY.

That will tell us who is seeing the error and thus
signalling the event (either PCI bus or the sundance
chip itself).

I don't know anything specific about the sundance
hardware though, sorry.
