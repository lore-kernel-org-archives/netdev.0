From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: drivers/infiniband/mlx/mad.c misplaced ;
Date: Thu, 16 Aug 2007 15:05:10 +0100
Message-ID: <46C45996.6060802@shadowen.org>
References: <20070815235825.GB17004@redhat.com> <1187224811.5906.55.camel@localhost> <46C3B428.4000003@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>,
	"Randy.Dunlap" <rdunlap@xenotime.net>,
	Joel Schopp <jschopp@austin.ibm.com>,
	Dave Jones <davej@redhat.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>, rolandd@cisco.com,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	Paul Mundt <lethal@linux-sh.org>,
	isdn4linux@listserv.isdn4linux.de, mikep@linuxtr.net,
	netdev@vger.kernel.org, swen@vnet.ibm.com, linux390@de.ibm.com,
	linux-s390@vger.kernel.org, jdike@karaya.com,
	user-mode-linux-devel@lists.sourceforge.net,
	user-mode-linux-user@lists.sourceforge.net,
	netfilter-devel@lists.netfilter.org, coreteam@netfilter.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hellhawk.shadowen.org ([80.68.90.175]:1423 "EHLO
	hellhawk.shadowen.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759309AbXHPOHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 10:07:25 -0400
In-Reply-To: <46C3B428.4000003@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Joe Perches wrote:
>> On Wed, 2007-08-15 at 19:58 -0400, Dave Jones wrote:
>>> Signed-off-by: Dave Jones <davej@redhat.com>
>>>
>>> diff --git a/drivers/infiniband/hw/mlx4/mad.c
>>> b/drivers/infiniband/hw/mlx4/mad.c
>>> index 3330917..0ed02b7 100644
>>> --- a/drivers/infiniband/hw/mlx4/mad.c
>>> +++ b/drivers/infiniband/hw/mlx4/mad.c
>>> @@ -109,7 +109,7 @@ int mlx4_MAD_IFC(struct mlx4_ib_dev *dev, int
>>> ignore_mkey, int ignore_bkey,
>>>                 in_modifier, op_modifier,
>>>                 MLX4_CMD_MAD_IFC, MLX4_CMD_TIME_CLASS_C);
>>>  
>>> -    if (!err);
>>> +    if (!err)
>>
>> There's more than a few of these (not inspected).
>>
>> $ egrep -r --include=*.c "\bif[[:space:]]*\([^\)]*\)[[:space:]]*\;" *
>> arch/sh/boards/se/7343/io.c:    if (0) ;
>> drivers/atm/iphase.c:     if (!desc1) ;
>> drivers/infiniband/hw/mlx4/mad.c:       if (!err);
>> drivers/isdn/capi/capiutil.c:   else if (c <= 0x0f);
>> drivers/net/tokenring/ibmtr.c:  else if (ti->shared_ram_paging ==
>> 0xf);  /* No paging in adapter */
>> drivers/s390/scsi/zfcp_erp.c:           if (status ==
>> ZFCP_ERP_SUCCEEDED) ;     /* no further action */
>> fs/hostfs/hostfs_user.c:        if(attrs->ia_valid & HOSTFS_ATTR_CTIME) ;
>> net/netfilter/xt_u32.c:         if (skb->len < 4 || pos > skb->len - 4);
>> sound/pci/au88x0/au88x0_synth.c:                                if
>> (eax == 0) ;
> 
> sounds like an excellent candidate check for checkpatch.pl !!!

Yep.  My scan of 2.6.23-rc3 with a checkpatch with this new test added,
found 6 which seemed wrong.

-apw
