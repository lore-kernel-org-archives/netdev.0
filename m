From: jamal <hadi@cyberus.ca>
Subject: Re: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed
	Topics
Date: 30 Mar 2005 11:55:09 -0500
Message-ID: <1112201709.1090.418.camel@jzny.localdomain>
References: <m1zmwn21hk.fsf@muc.de> <1112027284.5531.27.camel@mulgrave>
	 <20050329152008.GD63268@muc.de> <1112116762.5088.65.camel@beastie>
	 <1112130512.1077.107.camel@jzny.localdomain>
	 <20050330152208.GB12672@muc.de> <20050330153313.GD32111@g5.random>
	 <20050330153948.GE12672@muc.de> <20050330154418.GE32111@g5.random>
	 <20050330160255.GG12672@muc.de>  <20050330161522.GH32111@g5.random>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@muc.de>, Dmitry Yusupov <dmitry_yus@yahoo.com>,
        James Bottomley <James.Bottomley@HansenPartnership.com>,
        Rik van Riel <riel@redhat.com>, mpm@selenic.com, michaelc@cs.wisc.edu,
        open-iscsi@googlegroups.com, ksummit-2005-discuss@thunk.org,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrea Arcangeli <andrea@suse.de>
In-Reply-To: <20050330161522.GH32111@g5.random>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-03-30 at 11:15, Andrea Arcangeli wrote:

> > The problem with you algorithm is that you cannot control
> > how to NIC puts incoming packets into RX rings (and then 
> > actually if the packets you are interested in do actually arrive from
> > the net ,-)
> 
> All I care about is to assign a mempool ID to the skb (ID being unique
> identifier for the tcp connection I don't care how the implementation
> is). 

Mechanisms are in place today.

> If while moving up the stack the skb data doesn't match to the
> sock->mempool id, we'll just free the packet and put it back in the
> mempool.
> 

I think you may need to reserve some small amount of buffers per NIC 
(<= RX DMA ring size) that are used as temporary buffers before the
decision is made to reassign to the higher priority memory or drop. 
The decision, if s/ware only, would need to consult a classifier at the
ingress (hopefully you are using NAPI and kick this only on overload).
The upgrade implies restoring the temporary buffer to the NIC.
The NIC rx side only makes progress if temp buffers are available.
Since they are restored a short distance after they are allocated
(whether you drop or upgrade) progress will always happen

> > "We have an enterprise class OS with iSCSI which can only
> > support four swap devices"
> 

You forgot "carrier-grade" or is that supposed to conflict with
"enteprise class"? Cant you be both? ;->

> ;) I agree the hardware solution isn't appealing.

Well, if a realtek NIC (read: elcheapo, commodity) has such features -
in the minimal (regarless of the iscsi problem)- we need to support
those features.

cheers,
jamal
