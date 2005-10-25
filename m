From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 2/2] forcedeth: scatter gather and segmentation
 offload support
Date: Tue, 25 Oct 2005 15:05:19 -0700
Message-ID: <1130277919.6236.7.camel@rh4>
References: <DBFABB80F7FD3143A911F9E6CFD477B00BA5D790@hqemmail02.nvidia.com>
 <20051025215932.GA17794@electric-eye.fr.zoreil.com>
 <1130272203.6236.2.camel@rh4>
 <20051025232248.GB17794@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Ayaz Abdulla" <AAbdulla@nvidia.com>,
        "Stephen Hemminger" <shemminger@osdl.org>,
        "Jeff Garzik" <jgarzik@pobox.com>,
        "Manfred Spraul" <manfred@colorfullife.com>,
        "Netdev" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Francois Romieu" <romieu@fr.zoreil.com>
In-Reply-To: <20051025232248.GB17794@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-10-26 at 01:22 +0200, Francois Romieu wrote:
> Michael Chan <mchan@broadcom.com> :
> > Please explain what did you mean by bogus?
> 
> When the CPU sets the entries of a multi-descriptor packet, the first
> descriptor is marked read while the next ones are still unset.
> 

Not sure you you meant by "marked read", but none of the new tx
descriptors will be DMA'ed by the chip until we write the producer index
and the byte seq. number.

> If any of BNX2_L2CTX_TX_HOST_{BIDX/BSEQ} prevents the asic to read
> beyond 'prod' (or b(yte)seq ?), the ordering does not matter. Right ?
> 

Right, the chip will only DMA the tx descriptors up to the (prod - 1)
index. tg3 works in a similar way.
