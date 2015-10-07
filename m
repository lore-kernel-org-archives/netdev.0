From: Chad Dupuis <chad.dupuis@qlogic.com>
Subject: Re: [PATCH] bnx2fc: reduce stack usage in __bnx2fc_enable
Date: Wed, 7 Oct 2015 14:49:22 -0400
Message-ID: <alpine.OSX.2.00.1510071441460.1714@dns1.prod.a4.vary.redhat.com>
References: <5002023.QHmpbQ8s70@wuerfel> <56151E03.4050908@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"; format=flowed
Cc: Arnd Bergmann <arnd@arndb.de>, <linux-scsi@vger.kernel.org>,
	<QLogic-Storage-Upstream@qlogic.com>,
	"James E.J. Bottomley" <JBottomley@odin.com>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	Joe Carnuccio <joe.carnuccio@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Maurizio Lombardi <mlombard@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:36871 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752087AbbJGSuP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 14:50:15 -0400
In-Reply-To: <56151E03.4050908@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 7 Oct 2015, Maurizio Lombardi wrote:

> Hi,
>
> On 10/07/2015 03:11 PM, Arnd Bergmann wrote:
>> -	memset(&npiv_tbl, 0, sizeof(npiv_tbl));
>> -	if (hba->cnic->get_fc_npiv_tbl(hba->cnic, &npiv_tbl))
>> +	npiv_tbl = kzalloc(sizeof(struct cnic_fc_npiv_tbl), GFP_KERNEL);
>> +	if (!npiv_tbl)
>>  		goto done;
>>
>
> If kzalloc() fails perhaps the function should return -ENOMEM, not zero.
>

The enablement of the fcoe interface can still proceed if this particular 
allocation fails so returning 0 would be appropriate here.

This patch looks good to me.

>
> Regards,
> Maurizio Lombardi
>
