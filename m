From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH] ehea: Fixing LRO configuration
Date: Tue, 14 Dec 2010 12:55:47 -0800
Message-ID: <AANLkTimODzrAWS+05+FChtme_3um_9Ky7cwa3gWHFaXp@mail.gmail.com>
References: <1291833062-27446-1-git-send-email-leitao@linux.vnet.ibm.com>
	<AANLkTimvL2TdD9eYQMLZW65ESKbame818ObzjPYoBhPL@mail.gmail.com>
	<4D076AAF.5040505@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: shemminger@vyatta.com, davem@davemloft.net, netdev@vger.kernel.org
To: Breno Leitao <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f45.google.com ([209.85.215.45]:40257 "EHLO
	mail-ew0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759636Ab0LNUzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 15:55:48 -0500
Received: by ewy10 with SMTP id 10so727583ewy.4
        for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 12:55:47 -0800 (PST)
In-Reply-To: <4D076AAF.5040505@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 14, 2010 at 5:01 AM, Breno Leitao <leitao@linux.vnet.ibm.com> wrote:
> Hi Jesse,
>
> On 12/12/2010 10:39 PM, Jesse Gross wrote:
>>
>> I don't think that this should enable those vlan offloading flags.
>
> I just inserted ETH_FLAG_TXVLAN and ETH_FLAG_RXVLAN there because when I
> call ethtool -K ethX lro on/off, it sends the ETH_FLAG_LRO plus the vlan
> flags if they are enabled (and they are by default).
>
> So, if it doesn't make sense to be toggled, I can mask these flags at
> ehea_set_flags(). so that it doesn't arrive at ethtool_op_set_flags().

I think the right solution is to check that they are set before the
call to ethtool_op_set_flags() and return -EINVAL if not.  Masking
them out would result in turning the features off, which isn't a valid
state here.

Of course, the alternative is to actually add support for the settings
to be toggled.  This would be ideal but it doesn't look the driver
ever does that currently, so maybe it's not supported by hardware.

Thanks.
