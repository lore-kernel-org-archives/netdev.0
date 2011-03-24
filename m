From: Bhupesh SHARMA <bhupesh.sharma@st.com>
Subject: RE: c_can: TX handling
Date: Thu, 24 Mar 2011 13:43:06 +0800
Message-ID: <D5ECB3C7A6F99444980976A8C6D896384DF0D6F721@EAPEX1MAIL1.st.com>
References: <16a340801622a96218c76dbbabc7a23f.squirrel@www.linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "wg@grandegger.com" <wg@grandegger.com>,
	"kurt.van.dijck@eia.be" <kurt.van.dijck@eia.be>,
	"b.spranger@linutronix.de" <b.spranger@linutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Socketcan-core@lists.berlios.de" <Socketcan-core@lists.berlios.de>
To: Jan Altenberg <jan@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:58385 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932587Ab1CXFnx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Mar 2011 01:43:53 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jan,

> > I did some more testing on the SocketCAN driver for the Bosch c_can
> > controller and I observed some strange behaviour for the TX handling.
> > First of all the TX bytes are not accounted correctly. The reason for
> > that
> > seems to be quite obvious if we look into c_can_do_tx():
> >
> > [...]
> >
> > c_can_inval_msg_object(dev, 0, msg_obj_no);
> > val = c_can_read_reg32(priv, &priv->regs->txrqst1);
> > if (!(val & (1 << msg_obj_no))) {
> >         can_get_echo_skb(dev,
> >                         msg_obj_no - C_CAN_MSG_OBJ_TX_FIRST);
> >         stats->tx_bytes += priv->read_reg(priv,
> >                         &priv->regs->ifregs[0].msg_cntrl)
> >                         & IF_MCONT_DLC_MASK;
> >
> > So, we first invalidate the message object and afterwards we read the
> > DLC
> > value from the msg_cntrl (which is 0 after invalidating the
> > message object) to account the TX bytes. So tx_bytes will always be
> 0.
> > The
> > fix should be easy, I think, we can just move
> > c_can_inval_msg_object to the end of that loop.
> 
> Hmmm..
> As far as I remember, *ifconfig* used to provide the correct tx_bytes
> stats
> on my SPEAr board. Let me recheck this again today evening and get back
> to you.

I managed to get hold of one SPEAr board and did some quick tests.
Indeed the tx_bytes field is 0 when we execute *ifconfig*

I think the easy fix would be to add c_can_inval_msg_object(dev, 0, msg_obj_no);
call inside the *if* construct. Could you please prepare a patch after
testing the same at your end.

Regards,
Bhupesh
