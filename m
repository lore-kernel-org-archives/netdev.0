From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169 NAPI addition
Date: Mon, 19 Apr 2004 22:49:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040419224911.A17362@electric-eye.fr.zoreil.com>
References: <20040419202530.A16586@electric-eye.fr.zoreil.com> <OF39D4C0E0.23E33AF9-ON87256E7B.006F44E8-86256E7B.0072D05C@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon D Mason <jonmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OF39D4C0E0.23E33AF9-ON87256E7B.006F44E8-86256E7B.0072D05C@us.ibm.com>; from jonmason@us.ibm.com on Mon, Apr 19, 2004 at 03:57:55PM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon D Mason <jonmason@us.ibm.com> :
[...]
> Unsigned variables are a little bit faster on ppc hardware.  I figgured 
> that it doesn't matter on x86/x86_64, but would help other archatectures.

Ok. No objection against an unsigned int or an u32 instead ?

[...]
> >> +#ifdef CONFIG_R8169_NAPI
> >> +                       netif_receive_skb(skb);
> >> +#else
> >>                         netif_rx(skb);
> >> +#endif
> >I'd probably favor something like r8169_rx_skb() to avoid the flashy 
> #ifdef.
> 
> I can try and hide as many #ifdefs as possible if you like, just didn't 
> know your preferance. Will do.

(sometimes hch is bored and dissects network patches too :o) )

I have no suggestion for the others #ifdef but at least this one can be
isolated.

[...]
> >> +static int rtl8169_poll(struct net_device *dev, int *budget)
> >> +{
> >> +       uint32_t work_done = 0,
> >> +               work_to_do = min(*budget, dev->>quota);
> >
> >Please put this on a separate line after the declarations of the 
> variables.
> 
> This is declaration and assignment.  Would you prefer decleration and 
> assignment seperate?

Anything as long as it avoids the indentation of a line in the declaration
block.

[...]
> I could be wrong, but I don't think its possible to be in the poll 
> function with interrupts turned on.  The work scheduling is done in the 
> interrupt handler, which turns off the Rx interrupts.  I could turn off 

I fail to see where the Tx interrupts are disabled.

[...]
> Not sure the significance of RTL_W16 being a posted pci write.  Can you 
> clarify its significance for me?

The locking scheme which will be used between ->poll() and ->interrupt()
should guarantee some ordering of the registers operations (provided they
appear in the locked section). However, if no read is issued, no one knows
when the write will actually hit the chipset.

(I should probably check this in the epic100 changes as well)

> >Global remarks:
> >- you probably want a larger Rx ring;
> 
> It might be better to be a user turnable parameter, but I can increase the 
> size for NAPI useage.  Any perefance as to the ring size?

(wet finger in the wind)

256

[...]
> I hate Notes!  Be assured that they are tabs and not whitespaces.  If you 
> perfer, I can have the diffs as an attachment.

If it helps, please do.

> >Have you considered Tx napi ? :o)
> Actually, I have a copy of the driver that does Tx.  After reading the 
> NAPI howto, which states that there is a slight performance degridadtion 
> if Tx is NAPI too, I figgured that you would want only Rx.  I can add Tx 
> if you like.

Separate patches are usually easier to review, yes.

[...]
> Sorry, I will copy him on directly (instead of the indirect netdev).

Please keep netdev@oss.sgi.com Cced as well.

--
Ueimor
