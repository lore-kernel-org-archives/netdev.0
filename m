From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 1/9] liquidio CN23XX: HW config for VF
 support
Date: Thu, 20 Oct 2016 16:57:20 -0400 (EDT)
Message-ID: <20161020.165720.1537348879596195765.davem@davemloft.net>
References: <1476942046-18789-2-git-send-email-rvatsavayi@caviumnetworks.com>
        <20161020.141304.286994718471308700.davem@davemloft.net>
        <DM3PR07MB21387F2B6D44558DBC36649881D50@DM3PR07MB2138.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Derek.Chickles@cavium.com,
        Satananda.Burla@cavium.com, Felix.Manlunas@cavium.com
To: Raghu.Vatsavayi@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46266 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754103AbcJTU5W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 16:57:22 -0400
In-Reply-To: <DM3PR07MB21387F2B6D44558DBC36649881D50@DM3PR07MB2138.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Vatsavayi, Raghu" <Raghu.Vatsavayi@cavium.com>
Date: Thu, 20 Oct 2016 20:01:37 +0000

> 
> 
>> -----Original Message-----
>> From: David Miller [mailto:davem@davemloft.net]
>> Sent: Thursday, October 20, 2016 11:13 AM
>> To: Vatsavayi, Raghu
>> Cc: netdev@vger.kernel.org; Vatsavayi, Raghu; Chickles, Derek; Burla,
>> Satananda; Manlunas, Felix
>> Subject: Re: [PATCH net-next V2 1/9] liquidio CN23XX: HW config for VF
>> support
>> 
>> From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
>> Date: Wed, 19 Oct 2016 22:40:38 -0700
>> 
>> > +/* Default behaviour of Liquidio is to provide one queue per VF. But
>> > +Liquidio
>> > + * can also provide multiple queues to each VF. If user wants to
>> > +change the
>> > + * default behaviour HW should be provided configuration info at init
>> > +time,
>> > + * based on which it will create control queues for communicating with
>> FW.
>> > + */
>> > +static u32 max_vfs[2] = { 0, 0 };
>> > +module_param_array(max_vfs, int, NULL, 0444);
>> > +MODULE_PARM_DESC(max_vfs, "Assign two comma-separated unsigned
>> > +integers that specify max number of VFs for PF0 (left of the comma)
>> > +and PF1 (right of the comma); for 23xx only. By default HW will
>> > +configure as many VFs as queues after allocating PF queues.To
>> > +increase queues for VF use this parameter. Use sysfs to create these
>> > +VFs.");
>> > +
>> > +static unsigned int num_queues_per_pf[2] = { 0, 0 };
>> > +module_param_array(num_queues_per_pf, uint, NULL, 0444);
>> > +MODULE_PARM_DESC(num_queues_per_pf, "two comma-separated
>> unsigned
>> > +integers that specify number of queues per PF0 (left of the comma)
>> > +and PF1 (right of the comma); for 23xx only");
>> > +
>> >  static int ptp_enable = 1;
>> 
>> We cannot continue to allow drivers to add custom module parameters to
>> control this.  It is the worst user experience possible.
>> 
>> We need a tree-wide generic, consistent, manner in which to configure and
>> control this kind of thing.
> 
> Sure Dave, I will remove max_vfs module parameter and will use tree wide generic 
> sysfs interface to enable VFs.

That's not what I meant.

I mean there needs to be a generic mechanism that isn't a per-device
knob (be it a module parameter or a sysctl, to me these are identical
functionality and user experience wise).

Something like ethtool or netlink.
