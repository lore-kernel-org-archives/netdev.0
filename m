From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH net-next] net: hns: Fix to conditionally convey RX
 checksum flag to stack
Date: Tue, 29 Nov 2016 09:13:22 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F91A7C688B@lhreml503-mbs>
References: <20161125133240.1264224-1-salil.mehta@huawei.com>
 <20161128.121240.1321057221950786765.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lhrrgout.huawei.com ([194.213.3.17]:4628 "EHLO
        lhrrgout.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756513AbcK2JNh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 04:13:37 -0500
In-Reply-To: <20161128.121240.1321057221950786765.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, November 28, 2016 5:13 PM
> To: Salil Mehta
> Cc: Zhuangyuzeng (Yisen); mehta.salil.lnk@gmail.com;
> netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Linuxarm
> Subject: Re: [PATCH net-next] net: hns: Fix to conditionally convey RX
> checksum flag to stack
> 
> From: Salil Mehta <salil.mehta@huawei.com>
> Date: Fri, 25 Nov 2016 13:32:40 +0000
> 
> > @@ -778,6 +778,35 @@ int hns_ae_get_regs_len(struct hnae_handle
> *handle)
> >  	return total_num;
> >  }
> >
> > +static bool hns_ae_is_l3l4_csum_err(struct hnae_handle *handle)
> > +{
> > +	struct hns_ppe_cb *ppe_cb = hns_get_ppe_cb(handle);
> > +	u32 regval;
> > +	bool retval = false;
> > +
> > +	/* read PPE_HIS_PRO_ERR register and check for the checksum
> errors */
> > +	regval = dsaf_read_dev(ppe_cb, PPE_HIS_PRO_ERR_REG);
> > +
> 
> I don't see how a single register can properly provide error status for
> a ring
> of pending received packets.
> 
> No matter how this register is implemented, it is either going to
> result in
> packets erroneously being marked as having errors, or error status
> being
> lost when multiple packets in a row have such errors.
> 
> For example, if you receive several packets in a row that have errors,
> you'll read this register for the first one.  If this read clears the
> error
> status, which I am guessing it does, then you won't see the error
> status
> for the next packet that had one of these errors as well.
Agreed David. I think I missed this part. This register is 
not well thought of and looks useless for checksum. Thanks
for identifying this!

> 
> If you don't have something which is provided on a per-packet basis
> then you can't determine the error properly.  Therefore you will just
> have to always ignore the checksum if there is any error indicated in
> the ring descriptor.
Yes, will float another patch ignoring the checksum.

Thanks
Salil 
