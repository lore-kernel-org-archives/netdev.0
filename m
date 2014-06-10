From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH v4 5/6] net: fec: Add Scatter/gather support
Date: Tue, 10 Jun 2014 11:52:06 +0000
Message-ID: <8591edbcb6e3411dbc9d475e71ddb3fd@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1402392744-24368-1-git-send-email-b38611@freescale.com>
 <1402392744-24368-6-git-send-email-b38611@freescale.com>
 <063D6719AE5E284EB5DD2968C1650D6D1725A303@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ezequiel.garcia@free-electrons.com"
	<ezequiel.garcia@free-electrons.com>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0208.outbound.protection.outlook.com ([207.46.163.208]:27129
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751241AbaFJLw3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 07:52:29 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1725A303@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM> Sent: Tuesday, June 10, 2014 7:11 PM
>To: Duan Fugang-B38611; davem@davemloft.net
>Cc: netdev@vger.kernel.org; ezequiel.garcia@free-electrons.com; Li Frank-
>B20596; eric.dumazet@gmail.com
>Subject: RE: [PATCH v4 5/6] net: fec: Add Scatter/gather support
>
>From: Fugang Duan
>> Add Scatter/gather support for FEC.
>> This feature allows to improve outbound throughput performance.
>...
>> +static int fec_enet_get_free_txdesc_num(struct fec_enet_private *fep)
>> +{
>> +	int entries;
>> +
>> +	entries = ((const char *)fep->dirty_tx -
>> +			(const char *)fep->cur_tx) / fep->bufdesc_size;
>> +
>> +	return (fep->cur_tx >= fep->dirty_tx) ?
>> +		entries += fep->tx_ring_size : entries; }
>
>That is a strange return statement - why += ??
>
>You could also check the sign of 'entries'.
>Say:
>	return entries > 0 ? entries : entries + fep->tx_ring_size;
>
Agree your suggestion.

>Actually do you ever use the last entry?
>If you do then the full and empty conditions are not separated.
Don't use the last entry. When it is full condition, cur_tx is the last entry.
If (fep->cur_tx == fep->dirty_tx)
	Empty
If (fep->cur_tx == fep->dirty_tx - 1)
	Full

Since the patch set introduces tx_stop_threshold and tx_wake_threshold, it never uses the rest of entry while
Free entry number is less than tx_stop_threshold. 

Thanks,
Andy
