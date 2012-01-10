From: Maxim Uvarov <maxim.uvarov@oracle.com>
Subject: Re: [PATCHv2] bond_alb: don't disable softirq under bond_alb_xmit
Date: Mon, 09 Jan 2012 19:09:32 -0800
Message-ID: <4F0BABEC.2050200@oracle.com>
References: <1326146497-27711-1-git-send-email-maxim.uvarov@oracle.com> <20120109222046.GC32485@quad.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, Cong Wang <amwang@redhat.com>
To: Andy Gospodarek <gospo@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:50283 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932104Ab2AJDMG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 22:12:06 -0500
In-Reply-To: <20120109222046.GC32485@quad.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/09/2012 02:20 PM, Andy Gospodarek wrote:
> On Mon, Jan 09, 2012 at 02:01:37PM -0800, Maxim Uvarov wrote:
>> No need to lock soft irqs under bond_alb_xmit()
>> which already has softirq disabled.
>>
>> Changes:
>> 1. add non-bh/bh version to tlb_clear_slave()
>>
>> 2. represent BH and non BH hash table locks
>> _lock_rx_hashtbl_bh/_unlock_rx_hashtbl_bh
>> _lock_rx_hashtbl/_unlock_rx_hashtbl
>> _lock_tx_hashtbl_bh/_unlock_tx_hashtbl_bh
>> _lock_tx_hashtbl/_unlock_tx_hashtbl
>>
>> Signed-off-by: Maxim Uvarov<maxim.uvarov@oracle.com>
>> Signed-off-by: Cong Wang<amwang@redhat.com>
>> ---
>>   drivers/net/bonding/bond_alb.c |  112 +++++++++++++++++++++++++++-------------
>>   1 files changed, 76 insertions(+), 36 deletions(-)
>>
>
> Did you test this with CONFIG_DEBUG_LOCKDEP=y at all?
>

Just did some simple tests on bond0 with LOCKDEP. Do not see any warnings.

Maxim.
