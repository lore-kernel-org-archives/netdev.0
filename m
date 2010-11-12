From: "Tomoya MORINAGA" <tomoya-linux-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: Topcliff: PCH_CAN driver: Fix build
	warnings
Date: Fri, 12 Nov 2010 20:10:32 +0900
Message-ID: <004a01cb825a$3a8bd060$66f8800a@maildom.okisemi.com>
References: <4CCAA3D4.8070408@dsn.okisemi.com>
	<4CCAC4CD.7000503@pengutronix.de> <4CCAF517.2000409@pengutronix.de>
	<4CCB213A.2020206@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, margie.foster-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, joel.clark-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	kok.howg.ewe-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: "Wolfgang Grandegger" <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday, October 30, 2010 4:32 AM, Wolfgang Grandegger wrote :

Sorry, for my late.

> >> +
> >> +#define PCH_RX_OK 0x00000010
> >> +#define PCH_TX_OK 0x00000008
> >> +#define PCH_BUS_OFF 0x00000080
> >> +#define PCH_EWARN 0x00000040
> >> +#define PCH_EPASSIV 0x00000020
> >> +#define PCH_LEC0 0x00000001
> >> +#define PCH_LEC1 0x00000002
> >> +#define PCH_LEC2 0x00000004
> > 
> > These are just single set bit, please use BIT()
> > Consider adding the name of the corresponding register to the define's
> > name.

I agree.

> > 
> >> +#define PCH_LEC_ALL (PCH_LEC0 | PCH_LEC1 | PCH_LEC2)
> >> +#define PCH_STUF_ERR PCH_LEC0
> >> +#define PCH_FORM_ERR PCH_LEC1
> >> +#define PCH_ACK_ERR (PCH_LEC0 | PCH_LEC1)
> >> +#define PCH_BIT1_ERR PCH_LEC2
> >> +#define PCH_BIT0_ERR (PCH_LEC0 | PCH_LEC2)
> >> +#define PCH_CRC_ERR (PCH_LEC1 | PCH_LEC2)
> 
> This is an enumeration:
> 
> enum {
> PCH_STUF_ERR = 1,
> PCH_FORM_ERR,
> PCH_ACK_ERR,
> PCH_BIT1_ERR;
> PCH_BIT0_ERR,
> PCH_CRC_ERR,
> PCH_LEC_ALL;
> }

No, 
LEC is for bit assignment.
Thus, "enum" can't be used.


> >> +#define PCH_FIFO_THRESH 16
> >> +
> >> +enum pch_can_mode {
> >> + PCH_CAN_ENABLE,
> >> + PCH_CAN_DISABLE,
> >> + PCH_CAN_ALL,
> >> + PCH_CAN_NONE,
> >> + PCH_CAN_STOP,
> >> + PCH_CAN_RUN,
> >> +};
> >> +
> >> +struct pch_can_regs {
> >> + u32 cont;
> >> + u32 stat;
> >> + u32 errc;
> >> + u32 bitt;
> >> + u32 intr;
> >> + u32 opt;
> >> + u32 brpe;
> >> + u32 reserve1;
> > 
> > VVVV
> >> + u32 if1_creq;
> >> + u32 if1_cmask;
> >> + u32 if1_mask1;
> >> + u32 if1_mask2;
> >> + u32 if1_id1;
> >> + u32 if1_id2;
> >> + u32 if1_mcont;
> >> + u32 if1_dataa1;
> >> + u32 if1_dataa2;
> >> + u32 if1_datab1;
> >> + u32 if1_datab2;
> > ^^^^
> > 
> > these registers and....
> > 
> >> + u32 reserve2;
> >> + u32 reserve3[12];
> > 
> > ...and these
> > 
> > VVVV
> >> + u32 if2_creq;
> >> + u32 if2_cmask;
> >> + u32 if2_mask1;
> >> + u32 if2_mask2;
> >> + u32 if2_id1;
> >> + u32 if2_id2;
> >> + u32 if2_mcont;
> >> + u32 if2_dataa1;
> >> + u32 if2_dataa2;
> >> + u32 if2_datab1;
> >> + u32 if2_datab2;
> > 
> > ^^^^
> > 
> > ...are identical. I suggest to make a struct defining a complete
> > "Message Interface Register Set". If you include the correct number of
> > reserved bytes in the struct, you can have an array of two of these
> > structs in the struct pch_can_regs.
> 
> Yep, that would be nice. Using it consequently would also allow to
> remove duplicated code efficiently. I will name it "struct pch_can_if"
> for latter references.

I will modify like above.

> 
> > 
> >> + u32 reserve4;
> >> + u32 reserve5[20];
> >> + u32 treq1;
> >> + u32 treq2;
> >> + u32 reserve6[2];
> >> + u32 reserve7[56];
> >> + u32 reserve8[3];
> 
> Why not just one reserveX ?

I will modify to a reserveX.

> 
> >> + u32 srst;
> >> +};
> >> +
> >> +struct pch_can_priv {
> >> + struct can_priv can;
> >> + struct pci_dev *dev;
> >> + unsigned int tx_enable[MAX_MSG_OBJ];
> >> + unsigned int rx_enable[MAX_MSG_OBJ];
> >> + unsigned int rx_link[MAX_MSG_OBJ];
> >> + unsigned int int_enables;
> >> + unsigned int int_stat;
> >> + struct net_device *ndev;
> >> + spinlock_t msgif_reg_lock; /* Message Interface Registers Access Lock*/
> >                                                                             ^^^
> > please add a whitespace

I will modify.


> > 
> > IMHO the function name is missleading, if I understand the code
> > correctly, this functions triggers the transmission of the message.
> > After this it checks for busy, but 
> > 
> >> +static void pch_can_check_if_busy(u32 __iomem *creq_addr, u32 num)
> >                                      ^^^^
> > 
> > that should probaby be a void
> 
> With separate structs for if1 and i2, a pointer to the relevant "struct
> pch_can_if" could be passed instead.

I will modify

> >> +
> >> + if (set == 1) {
> >> + /* Setting the MsgVal and RxIE bits */
> >> + pch_can_bit_set(&priv->regs->if1_mcont, CAN_IF_MCONT_RXIE);
> >> + pch_can_bit_set(&priv->regs->if1_id2, CAN_ID_MSGVAL);
> >> +
> >> + } else if (set == 0) {
> >> + /* Resetting the MsgVal and RxIE bits */
> >> + pch_can_bit_clear(&priv->regs->if1_mcont, CAN_IF_MCONT_RXIE);
> >> + pch_can_bit_clear(&priv->regs->if1_id2, CAN_ID_MSGVAL);
> >> + }
> 
> Why not just?
> 
> if (set)
> else

I will modify.


> >> +static void pch_can_set_tx_enable(struct pch_can_priv *priv, u32 buff_num,
> >> + u32 set)
> >> +{
> >> + unsigned long flags;
> >> +
> >> + spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> >> + /* Reading the Msg buffer from Message RAM to Interface2 registers. */
> >> + iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
> >> + pch_can_check_if_busy(&priv->regs->if2_creq, buff_num);
> >> +
> >> + /* Setting the IF2CMASK register for accessing the
> >> + MsgVal and TxIE bits */
> >> + iowrite32(CAN_CMASK_RDWR | CAN_CMASK_ARB | CAN_CMASK_CTRL,
> >> + &priv->regs->if2_cmask);
> >> +
> >> + if (set == 1) {
> >> + /* Setting the MsgVal and TxIE bits */
> >> + pch_can_bit_set(&priv->regs->if2_mcont, CAN_IF_MCONT_TXIE);
> >> + pch_can_bit_set(&priv->regs->if2_id2, CAN_ID_MSGVAL);
> >> + } else if (set == 0) {
> >> + /* Resetting the MsgVal and TxIE bits. */
> >> + pch_can_bit_clear(&priv->regs->if2_mcont, CAN_IF_MCONT_TXIE);
> >> + pch_can_bit_clear(&priv->regs->if2_id2, CAN_ID_MSGVAL);
> >> + }
> >> +
> >> + pch_can_check_if_busy(&priv->regs->if2_creq, buff_num);
> >> + spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> >> +}
> 
> That function is almost identical to pch_can_set_rx_enable. Just if2 is
> used instead of if1 and CAN_IF_MCONT_TXIE instead of CAN_IF_MCONT_RXIE.
> With separate "struct  pch_can_if" for if1 and if2, it could be handled
> by a common function.

I will modify.

> 
> >> +static void pch_can_tx_enable_all(struct pch_can_priv *priv)
> >> +{
> >> + int i;
> >> +
> >> + /* Traversing to obtain the object configured as transmit object. */
> >> + for (i = PCH_RX_OBJ_NUM + 1; i <= PCH_OBJ_NUM; i++)
> >> + pch_can_set_tx_enable(priv, i, 1);
> >> +}
> >> +
> >> +static void pch_can_tx_disable_all(struct pch_can_priv *priv)
> >> +{
> >> + int i;
> >> +
> >> + /* Traversing to obtain the object configured as transmit object. */
> >> + for (i = PCH_RX_OBJ_NUM + 1; i <= PCH_OBJ_NUM; i++)
> >> + pch_can_set_tx_enable(priv, i, 0);
> >> +}
> 
> I think there is no need for separate functions for enable and disable.
> Just pass "enable" 0 or 1 like you do with "set" above.

I will modify

> 
> >> +static int pch_can_int_pending(struct pch_can_priv *priv)
> >           ^^^
> > 
> > make it u32 as it returns a register value, or a u16 as you only use
> > the 16 lower bits.

I will modify.

> > 
> >> +{
> >> + return ioread32(&priv->regs->intr) & 0xffff;
> >> +}
> >> +
> >> +static void pch_can_clear_buffers(struct pch_can_priv *priv)
> >> +{
> >> + int i; /* Msg Obj ID (1~32) */
> >> +
> >> + for (i = 1; i <= PCH_RX_OBJ_NUM; i++) {
> > 
> > IMHO the readability would be improved if you define something like
> > PCH_RX_OBJ_START and PCH_RX_OBJ_END.

I will modify.


> > 
> >> + iowrite32(CAN_CMASK_RX_TX_SET, &priv->regs->if1_cmask);
> >> + iowrite32(0xffff, &priv->regs->if1_mask1);
> >> + iowrite32(0xffff, &priv->regs->if1_mask2);
> >> + iowrite32(0x0, &priv->regs->if1_id1);
> >> + iowrite32(0x0, &priv->regs->if1_id2);
> >> + iowrite32(0x0, &priv->regs->if1_mcont);
> >> + iowrite32(0x0, &priv->regs->if1_dataa1);
> >> + iowrite32(0x0, &priv->regs->if1_dataa2);
> >> + iowrite32(0x0, &priv->regs->if1_datab1);
> >> + iowrite32(0x0, &priv->regs->if1_datab2);
> >> + iowrite32(CAN_CMASK_RDWR | CAN_CMASK_MASK |
> >> +   CAN_CMASK_ARB | CAN_CMASK_CTRL,
> >> +   &priv->regs->if1_cmask);
> >> + pch_can_check_if_busy(&priv->regs->if1_creq, i);
> >> + }
> >> +
> >> + for (i = PCH_RX_OBJ_NUM + 1; i <= PCH_OBJ_NUM; i++) {
> >                  ^^^^^^^^^^^^^^^^^^
> > dito for TX objects
> > 
> >> + iowrite32(CAN_CMASK_RX_TX_SET, &priv->regs->if2_cmask);
> >> + iowrite32(0xffff, &priv->regs->if2_mask1);
> >> + iowrite32(0xffff, &priv->regs->if2_mask2);
> >> + iowrite32(0x0, &priv->regs->if2_id1);
> >> + iowrite32(0x0, &priv->regs->if2_id2);
> >> + iowrite32(0x0, &priv->regs->if2_mcont);
> >> + iowrite32(0x0, &priv->regs->if2_dataa1);
> >> + iowrite32(0x0, &priv->regs->if2_dataa2);
> >> + iowrite32(0x0, &priv->regs->if2_datab1);
> >> + iowrite32(0x0, &priv->regs->if2_datab2);
> >> + iowrite32(CAN_CMASK_RDWR | CAN_CMASK_MASK | CAN_CMASK_ARB |
> >> +   CAN_CMASK_CTRL, &priv->regs->if2_cmask);
> >> + pch_can_check_if_busy(&priv->regs->if2_creq, i);
> 
> This is almost the same code as above, just if2 instead of if1. With
> separate "struct  pch_can_if" for if1 and i2, it could be handled by a
> common function.

I will modify.

> 
> >> + }
> >> +}
> >> +
> >> +static void pch_can_config_rx_tx_buffers(struct pch_can_priv *priv)
> >> +{
> >> + int i;
> >> + unsigned long flags;
> >> +
> >> + spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> >> +
> >> + for (i = 1; i <= PCH_RX_OBJ_NUM; i++) {
> >> + iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> >> + pch_can_check_if_busy(&priv->regs->if1_creq, i);
> > 
> > If I understand the code correctly, the about function triggers a
> > transfer. Why do you first trigger a transfer, then set the message contents....

For read-modify-write.


> >> + }
> >> +
> >> + if (status & PCH_LEC_ALL) {
> >> + priv->can.can_stats.bus_error++;
> >> + stats->rx_errors++;
> >> + switch (status & PCH_LEC_ALL) {
> > 
> > I suggest to convert to a if-bit-set because there might be more than
> > one bit set.
> 
> Marc, what do you mean here. It's an enumeraton. Maybe the following
> code is more clear:
> 
> lec = status & PCH_LEC_ALL;
> if (lec > 0) {
> switch (lec) {

No.
LEC is not enum.


> 
> >> + case PCH_STUF_ERR:
> >> + cf->data[2] |= CAN_ERR_PROT_STUFF;
> >> + break;
> >> + case PCH_FORM_ERR:
> >> + cf->data[2] |= CAN_ERR_PROT_FORM;
> >> + break;
> >> + case PCH_ACK_ERR:
> >> + cf->data[2] |= CAN_ERR_PROT_LOC_ACK |
> >> +        CAN_ERR_PROT_LOC_ACK_DEL;
> 
> Could you check what that type of bus error that is? Usually it's a ack
> lost error.

I will modify.
BTW, I can see ti_hecc also has the above the same code.

> 
> >> + break;
> >> + case PCH_BIT1_ERR:
> >> + case PCH_BIT0_ERR:
> >> + cf->data[2] |= CAN_ERR_PROT_BIT;
> >> + break;
> >> + case PCH_CRC_ERR:
> >> + cf->data[2] |= CAN_ERR_PROT_LOC_CRC_SEQ |
> >> +        CAN_ERR_PROT_LOC_CRC_DEL;
> >> + break;
> >> + default:
> >> + iowrite32(status | PCH_LEC_ALL, &priv->regs->stat);
> >> + break;
> >> + }
> >> +
> >> + }
> 
> Also, could you please add the TEC and REC:
> 
> cf->data[6] = ioread32(&priv->regs->errc) & CAN_TEC;
> cf->data[7] = (ioread32(&priv->regs->errc) & CAN_REC) >> 8;

I will add.
But I couldn't find 

> >> +
> >> +static int pch_can_rx_msg_lost(struct net_device *ndev, int obj_id)
> >> +{
> >> + struct pch_can_priv *priv = netdev_priv(ndev);
> >> + struct net_device_stats *stats = &(priv->ndev->stats);
> >> + struct sk_buff *skb;
> >> + struct can_frame *cf;
> >> +
> >> + dev_err(&priv->ndev->dev, "Msg Obj is overwritten.\n");
> 
> Please use dev_dbg or even remove the line above.

I will modify.


> 
> >> + pch_can_bit_clear(&priv->regs->if1_mcont,
> >> +   CAN_IF_MCONT_MSGLOST);
> >> + iowrite32(CAN_CMASK_RDWR | CAN_CMASK_CTRL,
> >> +   &priv->regs->if1_cmask);
> >> + pch_can_check_if_busy(&priv->regs->if1_creq, obj_id);
> 
> I think the if busy checks could be improved. Why do you need to wait here?

Sorry, I can' understand.
This is for clear MSGLOSG bit.

> 
> >> +
> >> + skb = alloc_can_err_skb(ndev, &cf);
> >> + if (!skb)
> >> + return -ENOMEM;
> >> +
> >> + priv->can.can_stats.error_passive++;
> >> + priv->can.state = CAN_STATE_ERROR_PASSIVE;
> 
> Please remove the above two bogus lines.

I will remove.


> >> +
> >> + can_get_echo_skb(ndev, int_stat - PCH_RX_OBJ_NUM - 1);
> >> + spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> >> + iowrite32(CAN_CMASK_RX_TX_GET | CAN_CMASK_CLRINTPND,
> >> +   &priv->regs->if2_cmask);
> >> + dlc = ioread32(&priv->regs->if2_mcont) & CAN_IF_MCONT_DLC;
> >> + pch_can_check_if_busy(&priv->regs->if2_creq, int_stat);
> >> + spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> >> + if (dlc > 8)
> >> + dlc = 8;
> > 
> > use get_can_dlc

I will use

> > 
> >> + stats->tx_bytes += dlc;
> >> + stats->tx_packets++;
> >> +}
> >> +
> >> +static int pch_can_rx_poll(struct napi_struct *napi, int quota)
> >> +{
> >> + struct net_device *ndev = napi->dev;
> >> + struct pch_can_priv *priv = netdev_priv(ndev);
> >> + u32 int_stat;
> >> + int rcv_pkts = 0;
> >> + u32 reg_stat;
> >> + unsigned long flags;
> >> +
> >> + int_stat = pch_can_int_pending(priv);
> >> + if (!int_stat)
> >> + goto END;
> 
> Labels should be lowercase as well.

I will modify

> 
> >> +
> >> + if ((int_stat == CAN_STATUS_INT) && (quota > 0)) {
> >> + reg_stat = ioread32(&priv->regs->stat);
> >> + if (reg_stat & (PCH_BUS_OFF | PCH_LEC_ALL)) {
> >> + if ((reg_stat & PCH_LEC_ALL) != PCH_LEC_ALL) {
> >> + pch_can_error(ndev, reg_stat);
> >> + quota--;
> >> + }
> >> + }
> >> +
> >> + if (reg_stat & PCH_TX_OK) {
> >> + spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> >> + iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
> >> + pch_can_check_if_busy(&priv->regs->if2_creq,
> >> +        ioread32(&priv->regs->intr));
> >                                                ^^^^^^^^^^^^^^^^^^^^^^^^^^^
> > 
> > Isn't this "int_stat". Might it be possilbe that regs->intr changes
> > between the pch_can_int_pending and here?
> > 
> > What should this transfer do?
> > 
> >> + spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> >> + pch_can_bit_clear(&priv->regs->stat, PCH_TX_OK);
> >> + }
> >> +
> >> + if (reg_stat & PCH_RX_OK)
> >> + pch_can_bit_clear(&priv->regs->stat, PCH_RX_OK);
> >> +
> >> + int_stat = pch_can_int_pending(priv);
> >> + }
> >> +
> >> + if (quota == 0)
> >> + goto END;
> >> +
> >> + if ((int_stat >= 1) && (int_stat <= PCH_RX_OBJ_NUM)) {
> >> + spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> >> + rcv_pkts += pch_can_rx_normal(ndev, int_stat, quota);
> >> + spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> >> + quota -= rcv_pkts;
> >> + if (rcv_pkts < 0)
> > 
> > how can this happen?

I will modify to quota.


> > 
> >> + goto END;
> >> + } else if ((int_stat > PCH_RX_OBJ_NUM) && (int_stat <= PCH_OBJ_NUM)) {
> >> + /* Handle transmission interrupt */
> >> + pch_can_tx_complete(ndev, int_stat);
> >> + }
> >> +
> >> +END:
> >> + napi_complete(napi);
> >> + pch_can_set_int_enables(priv, PCH_CAN_ALL);
> >> +
> >> + return rcv_pkts;
> >> +}
> >> +
> >> +static int pch_set_bittiming(struct net_device *ndev)
> >> +{
> >> + struct pch_can_priv *priv = netdev_priv(ndev);
> >> + const struct can_bittiming *bt = &priv->can.bittiming;
> >> + u32 canbit;
> >> + u32 bepe;
> >> +
> >> + /* Setting the CCE bit for accessing the Can Timing register. */
> >> + pch_can_bit_set(&priv->regs->cont, CAN_CTRL_CCE);
> >> +
> >> + canbit = (bt->brp - 1) & MSK_BITT_BRP;
> >> + canbit |= (bt->sjw - 1) << BIT_BITT_SJW;
> >> + canbit |= (bt->phase_seg1 + bt->prop_seg - 1) << BIT_BITT_TSEG1;
> >> + canbit |= (bt->phase_seg2 - 1) << BIT_BITT_TSEG2;
> >> + bepe = ((bt->brp - 1) & MSK_BRPE_BRPE) >> BIT_BRPE_BRPE;
> >> + iowrite32(canbit, &priv->regs->bitt);
> >> + iowrite32(bepe, &priv->regs->brpe);
> >> + pch_can_bit_clear(&priv->regs->cont, CAN_CTRL_CCE);
> >> +
> >> + return 0;
> >> +}
> >> +
> >> +static void pch_can_start(struct net_device *ndev)
> >> +{
> >> + struct pch_can_priv *priv = netdev_priv(ndev);
> >> +
> >> + if (priv->can.state != CAN_STATE_STOPPED)
> >> + pch_can_reset(priv);
> >> +
> >> + pch_set_bittiming(ndev);
> >> + pch_can_set_optmode(priv);
> >> +
> >> + pch_can_tx_enable_all(priv);
> >> + pch_can_rx_enable_all(priv);
> >> +
> >> + /* Setting the CAN to run mode. */
> >> + pch_can_set_run_mode(priv, PCH_CAN_RUN);
> >> +
> >> + priv->can.state = CAN_STATE_ERROR_ACTIVE;
> >> +
> >> + return;
> >> +}
> >> +
> >> +static int pch_can_do_set_mode(struct net_device *ndev, enum can_mode mode)
> >> +{
> >> + int ret = 0;
> >> +
> >> + switch (mode) {
> >> + case CAN_MODE_START:
> >> + pch_can_start(ndev);
> >> + netif_wake_queue(ndev);
> >> + break;
> >> + default:
> >> + ret = -EOPNOTSUPP;
> >> + break;
> >> + }
> >> +
> >> + return ret;
> >> +}
> >> +
> >> +static int pch_can_open(struct net_device *ndev)
> >> +{
> >> + struct pch_can_priv *priv = netdev_priv(ndev);
> >> + int retval;
> >> +
> >> + /* Regsitering the interrupt. */
> 
> Typo!

I will modify.

> 
> >> + retval = request_irq(priv->dev->irq, pch_can_interrupt, IRQF_SHARED,
> >> +      ndev->name, ndev);
> >> + if (retval) {
> >> + dev_err(&ndev->dev, "request_irq failed.\n");
> >> + goto req_irq_err;
> >> + }
> >> +
> >> + /* Open common can device */
> >> + retval = open_candev(ndev);
> >> + if (retval) {
> >> + dev_err(ndev->dev.parent, "open_candev() failed %d\n", retval);
> >> + goto err_open_candev;
> >> + }
> >> +
> >> + pch_can_init(priv);
> >> + pch_can_start(ndev);
> >> + napi_enable(&priv->napi);
> >> + netif_start_queue(ndev);
> >> +
> >> + return 0;
> >> +
> >> +err_open_candev:
> >> + free_irq(priv->dev->irq, ndev);
> >> +req_irq_err:
> >> + pch_can_release(priv);
> >> +
> >> + return retval;
> >> +}
> >> +
> >> +static int pch_close(struct net_device *ndev)
> >> +{
> >> + struct pch_can_priv *priv = netdev_priv(ndev);
> >> +
> >> + netif_stop_queue(ndev);
> >> + napi_disable(&priv->napi);
> >> + pch_can_release(priv);
> >> + free_irq(priv->dev->irq, ndev);
> >> + close_candev(ndev);
> >> + priv->can.state = CAN_STATE_STOPPED;
> >> + return 0;
> >> +}
> >> +
> >> +static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
> >> +{
> >> + unsigned long flags;
> >> + struct pch_can_priv *priv = netdev_priv(ndev);
> >> + struct can_frame *cf = (struct can_frame *)skb->data;
> >> + int tx_buffer_avail = 0;
> > 
> > What I'm totally missing is the TX flow controll. Your driver has to
> > ensure that the package leave the controller in the order that come
> > into the xmit function. Further you have to stop your xmit queue if
> > you're out of tx objects and reenable if you have a object free.
> > 
> > Use netif_stop_queue() and netif_wake_queue() for this.

I will add flow control.

> >> + }
> >> + if (cf->can_dlc > 2) {
> >> + u32 data1 = *((u16 *)&cf->data[2]);
> >> + iowrite32(data1, &priv->regs->if2_dataa2);
> >> + }
> >> + if (cf->can_dlc > 4) {
> >> + u32 data1 = *((u16 *)&cf->data[4]);
> >> + iowrite32(data1, &priv->regs->if2_datab1);
> >> + }
> >> + if (cf->can_dlc > 6) {
> >> + u32 data1 = *((u16 *)&cf->data[6]);
> >> + iowrite32(data1, &priv->regs->if2_datab2);
> >> + }
> 
> Could be handled by a loop.

Pending.


> 
> >> + can_put_echo_skb(skb, ndev, tx_buffer_avail - PCH_RX_OBJ_NUM - 1);
> >> +
> >> + /* Set the size of the data. */
> >> + iowrite32(cf->can_dlc, &priv->regs->if2_mcont);
> >> +
> >> + /* Update if2_mcont */
> >> + pch_can_bit_set(&priv->regs->if2_mcont,
> >> + CAN_IF_MCONT_NEWDAT | CAN_IF_MCONT_TXRQXT |
> >> + CAN_IF_MCONT_TXIE);
> > 
> > pleae first perpare your value, then write to hardware.
> > 
> >> +
> >> + if (tx_buffer_avail == PCH_RX_OBJ_NUM) /* If points tail of FIFO  */
> >> + pch_can_bit_set(&priv->regs->if2_mcont, CAN_IF_MCONT_EOB);
> > 
> > dito
> > 
> > Is EOB relevant for TX objects?
> > 
> >> + pch_can_check_if_busy(&priv->regs->if2_creq, tx_buffer_avail);
> >> + spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> >> +
> >> + return NETDEV_TX_OK;
> >> +}
> >> +
> >> +static const struct net_device_ops pch_can_netdev_ops = {
> >> + .ndo_open = pch_can_open,
> >> + .ndo_stop = pch_close,
> >> + .ndo_start_xmit = pch_xmit,
> >> +};
> >> +
> >> +static void __devexit pch_can_remove(struct pci_dev *pdev)
> >> +{
> >> + struct net_device *ndev = pci_get_drvdata(pdev);
> >> + struct pch_can_priv *priv = netdev_priv(ndev);
> >> +
> >> + unregister_candev(priv->ndev);
> >> + pci_iounmap(pdev, priv->regs);
> >> + if (priv->use_msi)
> >> + pci_disable_msi(priv->dev);
> >> + pci_release_regions(pdev);
> >> + pci_disable_device(pdev);
> >> + pci_set_drvdata(pdev, NULL);
> >> + free_candev(priv->ndev);
> >> +}
> >> +
> >> +#ifdef CONFIG_PM
> >> +static void pch_can_set_int_custom(struct pch_can_priv *priv)
> >> +{
> >> + /* Clearing the IE, SIE and EIE bits of Can control register. */
> >> + pch_can_bit_clear(&priv->regs->cont, CAN_CTRL_IE_SIE_EIE);
> >> +
> >> + /* Appropriately setting them. */
> >> + pch_can_bit_set(&priv->regs->cont,
> >> + ((priv->int_enables & MSK_CTRL_IE_SIE_EIE) << 1));
> >> +}
> >> +
> >> +/* This function retrieves interrupt enabled for the CAN device. */
> >> +static u32 pch_can_get_int_enables(struct pch_can_priv *priv)
> >> +{
> >> + /* Obtaining the status of IE, SIE and EIE interrupt bits. */
> >> + return (ioread32(&priv->regs->cont) & CAN_CTRL_IE_SIE_EIE) >> 1;
> >> +}
> >> +
> >> +static u32 pch_can_get_rx_enable(struct pch_can_priv *priv, u32 buff_num)
> >> +{
> >> + unsigned long flags;
> >> + u32 enable;
> >> +
> >> + spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> >> + iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if1_cmask);
> >> + pch_can_check_if_busy(&priv->regs->if1_creq, buff_num);
> >> +
> >> + if (((ioread32(&priv->regs->if1_id2)) & CAN_ID_MSGVAL) &&
> >> + ((ioread32(&priv->regs->if1_mcont)) &
> >> + CAN_IF_MCONT_RXIE))
> >> + enable = 1;
> >> + else
> >> + enable = 0;
> >> + spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> >> + return enable;
> >> +}
> >> +
> >> +static u32 pch_can_get_tx_enable(struct pch_can_priv *priv, u32 buff_num)
> >> +{
> >> + unsigned long flags;
> >> + u32 enable;
> >> +
> >> + spin_lock_irqsave(&priv->msgif_reg_lock, flags);
> >> +
> >> + iowrite32(CAN_CMASK_RX_TX_GET, &priv->regs->if2_cmask);
> >> + pch_can_check_if_busy(&priv->regs->if2_creq, buff_num);
> >> + if (((ioread32(&priv->regs->if2_id2)) & CAN_ID_MSGVAL) &&
> >> + ((ioread32(&priv->regs->if2_mcont)) &
> >> + CAN_IF_MCONT_TXIE)) {
> >> + enable = 1;
> >> + } else {
> >> + enable = 0;
> >> + }
> >> + spin_unlock_irqrestore(&priv->msgif_reg_lock, flags);
> >> +
> >> + return enable;
> >> +}
> 
> The above two functions could be handled by a common one passing "struct
> pch_can_if". See similar comments above.

I will modify like the same.


> As the driver has already been merged. Please provide incremental
> patches against the net-2.6 branch. Also, it would be nice if you could
> check in-order transmission and reception, e.g., with the can-utils
> program canfdtest:
> 
> http://svn.berlios.de/wsvn/socketcan/trunk/can-utils/canfdtest.c
> 

Thank you for your information.


------
Thanks,

Tomoya MORINAGA
OKI SEMICONDUCTOR CO., LTD.
