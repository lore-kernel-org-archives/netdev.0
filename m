From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v4 5/6] net: fec: Add Scatter/gather support
Date: Tue, 10 Jun 2014 12:02:42 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725A352@AcuExch.aculab.com>
References: <1402392744-24368-1-git-send-email-b38611@freescale.com>
 <1402392744-24368-6-git-send-email-b38611@freescale.com>
 <063D6719AE5E284EB5DD2968C1650D6D1725A303@AcuExch.aculab.com>
 <8591edbcb6e3411dbc9d475e71ddb3fd@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ezequiel.garcia@free-electrons.com"
	<ezequiel.garcia@free-electrons.com>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: "'fugang.duan@freescale.com'" <fugang.duan@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:33772 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750883AbaFJMD2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 08:03:28 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 10309-02 for <netdev@vger.kernel.org>;
 Tue, 10 Jun 2014 13:03:19 +0100 (BST)
In-Reply-To: <8591edbcb6e3411dbc9d475e71ddb3fd@BLUPR03MB373.namprd03.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fugang.duan@freescale.com 
> From: David Laight <David.Laight@ACULAB.COM> Sent: Tuesday, June 10, 2014 7:11 PM
> >To: Duan Fugang-B38611; davem@davemloft.net
> >Cc: netdev@vger.kernel.org; ezequiel.garcia@free-electrons.com; Li Frank-
> >B20596; eric.dumazet@gmail.com
> >Subject: RE: [PATCH v4 5/6] net: fec: Add Scatter/gather support
> >
> >From: Fugang Duan
> >> Add Scatter/gather support for FEC.
> >> This feature allows to improve outbound throughput performance.
> >...
> >> +static int fec_enet_get_free_txdesc_num(struct fec_enet_private *fep)
> >> +{
> >> +	int entries;
> >> +
> >> +	entries = ((const char *)fep->dirty_tx -
> >> +			(const char *)fep->cur_tx) / fep->bufdesc_size;
> >> +
> >> +	return (fep->cur_tx >= fep->dirty_tx) ?
> >> +		entries += fep->tx_ring_size : entries; }
...
> >Actually do you ever use the last entry?
> >If you do then the full and empty conditions are not separated.

> Don't use the last entry. When it is full condition, cur_tx is the last entry.
> If (fep->cur_tx == fep->dirty_tx)
> 	Empty
> If (fep->cur_tx == fep->dirty_tx - 1)
> 	Full
> 
> Since the patch set introduces tx_stop_threshold and tx_wake_threshold,
> it never uses the rest of entry while
> Free entry number is less than tx_stop_threshold.

In which case I'd expect fec_enet_get_free_txdesc_num() to return
one less than it does currently.
Maybe the check for 'enough space' is 'needed < fec_enet_get_free_txdesc_num()'
(rather than <=)

	David
