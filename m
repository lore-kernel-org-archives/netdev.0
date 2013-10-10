From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: RE: [PATCH net-next 01/10] qlcnic: Print informational messages
 only once during driver load.
Date: Thu, 10 Oct 2013 12:41:37 +0000
Message-ID: <290BEC245535C3449143D5D84900EEF78CDBD1AE@avmb3.qlogic.org>
References: <cover.1380937706.git.himanshu.madhani@qlogic.com>
	<5fea5316a6664e19c516bbd26428a5034657b130.1380937706.git.himanshu.madhani@qlogic.com>
 <20131004142938.4ab6c6aa@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:52304 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751821Ab3JJMll convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Oct 2013 08:41:41 -0400
In-Reply-To: <20131004142938.4ab6c6aa@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stephen Hemminger [mailto:stephen@networkplumber.org]
> Sent: Saturday, October 05, 2013 3:00 AM
> To: Himanshu Madhani
> Cc: David Miller; netdev; Dept-NX Linux NIC Driver; Sucheta Chakraborty
> Subject: Re: [PATCH net-next 01/10] qlcnic: Print informational
> messages only once during driver load.
> 
> On Fri, 4 Oct 2013 14:30:48 -0400
> Himanshu Madhani <himanshu.madhani@qlogic.com> wrote:
> 
> > From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
> >
> > Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
> > Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
> > ---
> >  drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  1 +
> >  .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    | 12 -----------
> >  .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c  | 25
> ++++++++++++++++++----
> >  drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  1 +
> >  4 files changed, 23 insertions(+), 16 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> > b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> > index 81bf836..a3c4379 100644
> > --- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> > +++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
> > @@ -1199,6 +1199,7 @@ struct qlcnic_npar_info {
> >  	u8	promisc_mode;
> >  	u8	offload_flags;
> >  	u8      pci_func;
> > +	u8      mac[ETH_ALEN];
> >  };
> >
> 
> >
> 
> There is a field in netdevice which should probably be used for this
> perm_addr.
> 

This information is logged from the management function in Virtual NIC mode.
Management function do not a have access to the netdev info structure of other functions.
So we cannot make the changes as suggested.

> And then this could be corrected:
> 
> static void qlcnic_dcb_get_perm_hw_addr(struct net_device *netdev, u8
> *addr) {
> 	memcpy(addr, netdev->dev_addr, netdev->addr_len); }

Will incorporate this change in "dcb cleanup patch".

Thanks,
Sucheta.
