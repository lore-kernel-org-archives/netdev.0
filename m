From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: can: c_can: TX echo
Date: Wed, 23 Mar 2011 09:51:33 +0100
Message-ID: <20110323085133.GB346@e-circ.dyndns.org>
References: <16a340801622a96218c76dbbabc7a23f.squirrel@www.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: bhupesh.sharma@st.com, wg@grandegger.com, b.spranger@linutronix.de,
	netdev@vger.kernel.org
To: Jan Altenberg <jan@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.eia.be ([194.78.71.18]:22324 "EHLO mail.eia.be"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755793Ab1CWIvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Mar 2011 04:51:44 -0400
Content-Disposition: inline
In-Reply-To: <16a340801622a96218c76dbbabc7a23f.squirrel@www.linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm not too familiar with the c_can chip.
So I have a few questions inside my reply.

On Tue, Mar 22, 2011 at 04:59:23PM +0100, Jan Altenberg wrote:
> Hi all,
> 
> I did some more testing on the SocketCAN driver for the Bosch c_can
> controller and I observed some strange behaviour for the TX handling.
> First of all the TX bytes are not accounted correctly. The reason for that
> seems to be quite obvious if we look into c_can_do_tx():
> 
> [...]
> 
> c_can_inval_msg_object(dev, 0, msg_obj_no);
> val = c_can_read_reg32(priv, &priv->regs->txrqst1);
> if (!(val & (1 << msg_obj_no))) {
>         can_get_echo_skb(dev,
>                         msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
>         stats->tx_bytes += priv->read_reg(priv,
>                         &priv->regs->ifregs[0].msg_cntrl)
>                         & IF_MCONT_DLC_MASK;
> 
> So, we first invalidate the message object and afterwards we read the DLC
> value from the msg_cntrl (which is 0 after invalidating the
> message object) to account the TX bytes. So tx_bytes will always be 0. The
> fix should be easy, I think, we can just move
> c_can_inval_msg_object to the end of that loop.

IMO, it looks necessary to call c_can_inval_msg_object inside the if (),
after it has been transmitted. Otherwise, if for some other (TX) reason you
get in this loop, you may clear a pending transmission?
Again, I haven't read this one's datasheet. I was familiar with its predecessor.
> 
> Cheers,
>         Jan

Regards,
Kurt
