From: Stefan Raspl <raspl@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/2] Display adjacent switch port's attributes
Date: Thu, 12 Dec 2013 14:57:18 +0100
Message-ID: <52A9C0BE.5090801@linux.vnet.ibm.com>
References: <1386768540-48188-1-git-send-email-raspl@linux.vnet.ibm.com> <20131211121357.4742d9e8@nehalam.linuxnetplumber.net>
Reply-To: raspl@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, bhutchings@solarflare.com,
	blaschka@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:45410 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492Ab3LLN5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 08:57:24 -0500
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <raspl@linux.vnet.ibm.com>;
	Thu, 12 Dec 2013 13:57:22 -0000
In-Reply-To: <20131211121357.4742d9e8@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 11.12.2013 21:13, schrieb Stephen Hemminger:
> On Wed, 11 Dec 2013 14:28:58 +0100
> Stefan Raspl <raspl@linux.vnet.ibm.com> wrote:
> 
>> This patch series adds a new callback for ethtool to display the adjacent switch
>> port's attributes, as perceived by the NIC, e.g. through respective LLDP message
>> exchanges.
>> A patch for the qeth device driver provides a sample exploiter for the new
>> functionality.
>> A new option for ethtool to display the settings will be posted in a separate
>> patch.
>>
>> Best regards,
>> Stefan Raspl
>>
>> Stefan Raspl (2):
>>   ethtool: Add callback to indicate adjacent switch port attributes
>>   qeth: Display adjacent switch port attributes in ethtool
>>
>>  drivers/s390/net/qeth_core.h      |  7 ++++
>>  drivers/s390/net/qeth_core_main.c | 79 +++++++++++++++++++++++++++++++++++++++
>>  drivers/s390/net/qeth_core_mpc.h  | 17 +++++++++
>>  drivers/s390/net/qeth_l2_main.c   |  1 +
>>  drivers/s390/net/qeth_l3_main.c   |  1 +
>>  include/linux/ethtool.h           |  3 ++
>>  include/uapi/linux/ethtool.h      | 35 +++++++++++++++++
>>  net/core/ethtool.c                | 22 +++++++++++
>>  8 files changed, 165 insertions(+)
>>
> 
> Why more ethtool and not netlink? ethtool is a brittle interface, non-extensible
> and does not support notifications of changes.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I agree, netlink would certainly be nice. But ethtool is the
de-facto standard for now, and there doesn't seem to be a
netlink-based alternative in sight - or is there?
Offering a netlink based tool seems to be a different discussion,
and if that takes shape, existing ethtool functionality (including
this series) can and should be migrated.
