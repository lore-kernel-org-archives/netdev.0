From: <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net-next-2.6 2/2] be2net: use stats-sync to read/write
 64-bit stats
Date: Tue, 26 Jul 2011 22:34:36 -0700
Message-ID: <3367B80B08154D42A3B2BC708B5D41F63FFD9AC260@EXMAIL.ad.emulex.com>
References: <1311657015-23465-1-git-send-email-sathya.perla@emulex.com>
	<1311657015-23465-3-git-send-email-sathya.perla@emulex.com>
 <20110726075826.26bca7a9@s6510.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:49579 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750736Ab1G0Ff2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2011 01:35:28 -0400
In-Reply-To: <20110726075826.26bca7a9@s6510.ftrdhcpuser.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Stephen Hemminger [mailto:shemminger@vyatta.com]
>Sent: Tuesday, July 26, 2011 8:28 PM
>
>On Tue, 26 Jul 2011 10:40:15 +0530
>Sathya Perla <sathya.perla@emulex.com> wrote:
>
>> 64-bit stats in be2net are written/read as follows using the stats-sync
>> interface for safe access in 32-bit archs:
>>
>> 64-bit 		sync			writer			reader
>> stats
>> --------------------------------------------------------------------------
>----
>> tx_stats	tx_stats->sync		be_xmit			be_get_stats64,
>> 								ethtool
>> tx-compl	tx_stats->sync_compl	tx-compl-processing	ethtool
>> rx-stats	rx_stats->sync		rx-compl-processing	be_get_stats64,
>> 								ethtool,
>> 								eqd-update
>>
>> This patch is based on Stephen Hemminger's earlier patch on the same
>issue...
>>
>> Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
>
>Is the tx complete stat even worth the effort? does it provide a useful
>metric?
>Since rx/tx bytes are already in regular stats, keeping them in ethtool
>stats
>is redundant.
>
>These are just minor nits, you can ignore this advice if you want.

Stephen, in the 1/2 patch (in this set) I did remove the aggregate rx/tx bytes & pkts
from ethtool to avoid duplication. I've retained the *per-ring* stats in
ethtool as they are not provided by be_get_stats64().

The per-ring tx-compl stat, has helped on occasion in field debugging.
