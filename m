From: Mark Einon <mark.einon@gmail.com>
Subject: Re: [PATCH V2 15/20] qlcnic: 83xx adpater flash interface routines
Date: Fri, 19 Oct 2012 23:21:59 +0100
Message-ID: <CANK3SE1csTcxXYZLWRa7aqRCbvvJN3cKk=iuFYPd+GMKA6auQQ@mail.gmail.com>
References: <1350635858-27549-1-git-send-email-sony.chacko@qlogic.com> <1350635858-27549-16-git-send-email-sony.chacko@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: Sony Chacko <sony.chacko@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:43315 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933091Ab2JSWWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 18:22:15 -0400
Received: by mail-qa0-f46.google.com with SMTP id c26so388892qad.19
        for <netdev@vger.kernel.org>; Fri, 19 Oct 2012 15:22:14 -0700 (PDT)
In-Reply-To: <1350635858-27549-16-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19 October 2012 09:37, Sony Chacko <sony.chacko@qlogic.com> wrote:
>
> +static int qlcnic_83xx_enable_flash_write_op(struct qlcnic_adapter *adapter)
> +{
> +       int ret;
> +       u32 cmd;
> +       cmd = adapter->ahw->fdt.write_statusreg_cmd;
> +       qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_ADDR,
> +                                    (QLC_83XX_FLASH_FDT_WRITE_DEF_SIG | cmd));
> +       qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_WRDATA,
> +                                    adapter->ahw->fdt.write_enable_bits);
> +       qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_CONTROL,
> +                                    QLC_83XX_FLASH_SECOND_ERASE_MS_VAL);
> +       ret = qlcnic_83xx_poll_flash_status_reg(adapter);
> +       if (ret)
> +               return -EIO;
> +
> +       return 0;
> +}
> +
> +static int qlcnic_83xx_disable_flash_write_op(struct qlcnic_adapter *adapter)
> +{
> +       int ret;
> +
> +       qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_ADDR,
> +                                    (QLC_83XX_FLASH_FDT_WRITE_DEF_SIG |
> +                                    adapter->ahw->fdt.write_statusreg_cmd));
> +       qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_WRDATA,
> +                                    adapter->ahw->fdt.write_enable_bits);
> +       qlcnic_83xx_wrt_reg_indirect(adapter, QLC_83XX_FLASH_CONTROL,
> +                                    QLC_83XX_FLASH_SECOND_ERASE_MS_VAL);
> +       ret = qlcnic_83xx_poll_flash_status_reg(adapter);
> +       if (ret)
> +               return -EIO;
> +
> +       return 0;
> +}

The functions qlcnic_83xx_disable_flash_write_op() and
qlcnic_83xx_enable_flash_write_op() above do exactly the same thing.

This could be a bug, or at the very least one function will do.

Cheers,

Mark
