From: Sony Chacko <sony.chacko@qlogic.com>
Subject: RE: [PATCH V2 15/20] qlcnic: 83xx adpater flash interface routines
Date: Fri, 19 Oct 2012 18:17:06 -0700
Message-ID: <A26832265F3C994CBA2F7DA55BFAE70E74A0AEA6C0@AVEXMB2.qlogic.org>
References: <1350635858-27549-1-git-send-email-sony.chacko@qlogic.com>
 <1350635858-27549-16-git-send-email-sony.chacko@qlogic.com>
 <CANK3SE1csTcxXYZLWRa7aqRCbvvJN3cKk=iuFYPd+GMKA6auQQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Mark Einon <mark.einon@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe004.messaging.microsoft.com ([216.32.181.184]:57716
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759439Ab2JTBRc convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 21:17:32 -0400
In-Reply-To: <CANK3SE1csTcxXYZLWRa7aqRCbvvJN3cKk=iuFYPd+GMKA6auQQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 From: Mark Einon [mailto:mark.einon@gmail.com]
> Sent: Friday, October 19, 2012 3:22 PM
> To: Sony Chacko
> Cc: David Miller; netdev; Dept-NX Linux NIC Driver
> Subject: Re: [PATCH V2 15/20] qlcnic: 83xx adpater flash interface routines
> 
> On 19 October 2012 09:37, Sony Chacko <sony.chacko@qlogic.com> wrote:
> >
> > +static int qlcnic_83xx_enable_flash_write_op(struct qlcnic_adapter
> > +*adapter) {
> > +       int ret;
> > +       u32 cmd;
> > +       cmd = adapter->ahw->fdt.write_statusreg_cmd;
> > +       qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_ADDR,
> > +                                    (QLC_83XX_FLASH_FDT_WRITE_DEF_SIG | cmd));
> > +       qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_WRDATA,
> > +                                    adapter->ahw->fdt.write_enable_bits);
> > +       qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_CONTROL,
> > +                                    QLC_83XX_FLASH_SECOND_ERASE_MS_VAL);
> > +       ret = qlcnic_83xx_poll_flash_status_reg(adapter);
> > +       if (ret)
> > +               return -EIO;
> > +
> > +       return 0;
> > +}
> > +
> > +static int qlcnic_83xx_disable_flash_write_op(struct qlcnic_adapter
> > +*adapter) {
> > +       int ret;
> > +
> > +       qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_ADDR,
> > +                                    (QLC_83XX_FLASH_FDT_WRITE_DEF_SIG |
> > +                                    adapter->ahw->fdt.write_statusreg_cmd));
> > +       qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_WRDATA,
> > +                                    adapter->ahw->fdt.write_enable_bits);
> > +       qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_CONTROL,
> > +                                    QLC_83XX_FLASH_SECOND_ERASE_MS_VAL);
> > +       ret = qlcnic_83xx_poll_flash_status_reg(adapter);
> > +       if (ret)
> > +               return -EIO;
> > +
> > +       return 0;
> > +}
> 
> The functions qlcnic_83xx_disable_flash_write_op() and
> qlcnic_83xx_enable_flash_write_op() above do exactly the same thing.
> 
> This could be a bug, or at the very least one function will do.
> 
> Cheers,
> 
> Mark

Thanks for the review, it is a bug. We will fix it in the next version of the patch series.
Sony
