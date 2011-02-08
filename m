From: Bhupesh SHARMA <bhupesh.sharma-qxv4g6HH51o@public.gmane.org>
Subject: RE: [PATCH net-next-2.6 v5 1/1] can: c_can: Added support for Bosch
	C_CAN controller
Date: Tue, 8 Feb 2011 19:36:56 +0800
Message-ID: <D5ECB3C7A6F99444980976A8C6D896384DEE365F14@EAPEX1MAIL1.st.com>
References: <D5ECB3C7A6F99444980976A8C6D896384DEE2BE326@EAPEX1MAIL1.st.com>
	<4D511B4E.1090001@grandegger.com>
	<D5ECB3C7A6F99444980976A8C6D896384DEE365EE8@EAPEX1MAIL1.st.com>
	<4D5128C8.1060208@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org" <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4D5128C8.1060208-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Content-Language: en-US
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



> -----Original Message-----
> From: Wolfgang Grandegger [mailto:wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org]
> Sent: Tuesday, February 08, 2011 4:58 PM
> To: Bhupesh SHARMA
> Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Marc
> Kleine-Budde
> Subject: Re: [PATCH net-next-2.6 v5 1/1] can: c_can: Added support for
> Bosch C_CAN controller
> 
> On 02/08/2011 11:45 AM, Bhupesh SHARMA wrote:
> >> -----Original Message-----
> >> From: Wolfgang Grandegger [mailto:wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org]
> >> Sent: Tuesday, February 08, 2011 4:01 PM
> >> To: Bhupesh SHARMA
> >> Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Marc
> >> Kleine-Budde
> >> Subject: Re: [PATCH net-next-2.6 v5 1/1] can: c_can: Added support
> for
> >> Bosch C_CAN controller
> >>
> >> On 02/08/2011 10:04 AM, Bhupesh SHARMA wrote:
> >>> Hi Wolfgang,
> >>>
> >>>>> + stats->rx_errors++;
> >>>>> + cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
> >>>>> + cf->data[2] |= CAN_ERR_PROT_UNSPEC;
> >>>>> +
> >>>>> + switch (lec_type) {
> >>>>> + case LEC_STUFF_ERROR:
> >>>>> + netdev_dbg(dev, "stuff error\n");
> >>>>> + cf->data[2] |= CAN_ERR_PROT_STUFF;
> >>>>> + break;
> >>>>> +
> >>>>> + case LEC_FORM_ERROR:
> >>>>> + netdev_dbg(dev, "form error\n");
> >>>>> + cf->data[2] |= CAN_ERR_PROT_FORM;
> >>>>> + break;
> >>>>> +
> >>>>> + case LEC_ACK_ERROR:
> >>>>> + netdev_dbg(dev, "ack error\n");
> >>>>> + cf->data[2] |= (CAN_ERR_PROT_LOC_ACK |
> >>>>> + CAN_ERR_PROT_LOC_ACK_DEL);
> >>>>> + break;
> >>>>> +
> >>>>> + case LEC_BIT1_ERROR:
> >>>>> + netdev_dbg(dev, "bit1 error\n");
> >>>>> + cf->data[2] |= CAN_ERR_PROT_BIT1;
> >>>>> + break;
> >>>>> +
> >>>>> + case LEC_BIT0_ERROR:
> >>>>> + netdev_dbg(dev, "bit0 error\n");
> >>>>> + cf->data[2] |= CAN_ERR_PROT_BIT0;
> >>>>> + break;
> >>>>> +
> >>>>> + case LEC_CRC_ERROR:
> >>>>> + netdev_dbg(dev, "CRC error\n");
> >>>>> + cf->data[2] |= (CAN_ERR_PROT_LOC_CRC_SEQ |
> >>>>> + CAN_ERR_PROT_LOC_CRC_DEL);
> >>>>> + break;
> >>>>> + }
> >>>
> >>> >From the C_CAN manual:
> >>>>
> >>>> "The LEC field holds a code which indicates the type of the last
> >> error
> >>>> to occur on the CAN bus. This field will be cleared to '0' when a
> >>>> message has been transferred (reception or transmission) without
> >> error.
> >>>> The unused code '7' may be written by the CPU to check for
> updates."
> >>>
> >>>> Not sure if it's necessary to reset the lec at init and after an
> >> error
> >>>> to 0x7 and check it. More below...
> >>>
> >>> I worked on your suggestion and instead found that the follow algo
> >> must be used
> >>> for reading updated `lec` values:
> >>> a. Init lec by 0x07 at start.
> >>> b. In function `c_can_err` check if lec is 0x7 (no bus error since
> >> this value was
> >>> written by CPU on status register) or 0x0 (no error). If so, return
> >> without
> >>> sending an error frame on stack. Else, check for the lec error type
> >> and
> >>> submit error frame on stack accordingly.
> >>> c. In case a lec error is found and served in `c_can_err` routine,
> >> write
> >>> lec value to 0x07 again in status reg to check for updated lec
> later.
> >>>
> >>> This is my understanding after reading the specs time and again and
> >>> implementing/testing the logic.
> >>>
> >>> Do you think this is fine or do you have any better approach?
> >>
> >> That's what I remember from the CC770 driver. Search for lec in:
> >>
> >>
> http://svn.berlios.de/wsvn/socketcan/trunk/kernel/2.6/drivers/net/can/c
> >> c770/cc770.c
> >>
> >
> > Seems similar. But step (c) mentioned above seems missing from
> cc770.c driver,
> > i.e. "In case a lec error is found and served (by means of sending an
> error
> > frame on the bus) write lec value to 0x07 again in status reg to
> check for updated
> > lec later-on. In my view seems logical to add it also.
> 
> It's done in cc770_status_interrupt():
> 
>         status = cc770_read_reg(priv, status);
>         /* Reset the status register including RXOK and TXOK */
>         cc770_write_reg(priv, status, STAT_LEC_MASK);
> 
Oops.. Sorry it seems I missed it.
Many Thanks for your help and comments.

Regards,
Bhupesh
