From: Christian =?iso-8859-15?q?Borntr=E4ger?= <christian@borntraeger.net>
Subject: Re: [PATCH] ipv6: alternative version of S/390 shared NIC support
Date: Tue, 18 Jan 2005 00:37:57 +0100
Message-ID: <200501180037.58453.christian@borntraeger.net>
References: <20050116115431.GA13617@lst.de> <20050117225946.GA11845@lst.de> <1106003481.1035.35.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>,
        pavlic@de.ibm.com, waldi@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1106003481.1035.35.camel@jzny.localdomain>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2005-01-17 at 17:59, Christoph Hellwig wrote:
> > The problem is again that the OS instances don't talk to each
> > (well they can, but not in the driver), so your demux code would
> > have to move into the device firmware, and that'd probably change
> > the device <-> OS interface completely.
>
> qeth_qdio_input_handler() seems to know what "card" the packet came on,
> no? Could you not use this information to select the proper netdevice?
> Actually, how does that work? Each OS instance would get the same driver
> invoked but you will never see any othe instances "cards"?

I am trying a small simplification here:
Each physical network adapter offers hundreds of device addresses. You need 
3 of them to have one logical network adapter(read,write,data). S/390 has 
hardware supported virtualization. Therefore can then use the hypervisor 
(LPAR or z/VM) to give specific LPARs or VM guests exactly 3 device 
addresses out of these hundreds. 
The qeth driver has to register the IP address at the logical network card 
(using 3 device addresses) Afterwards the physical network card knows which 
packet belongs to which device numbers.

cheers Christian
