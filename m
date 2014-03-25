From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH] net/mlx4_core: pass pci_dev_data to __mlx4_init_one
Date: Tue, 25 Mar 2014 22:06:45 +0800
Message-ID: <20140325140644.GA7434@richard>
References: <1395636171-17347-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <CAJZOPZLM+fRBqA_rkgiUO5FCd1YtzsCKN3=denHW6Tx7OHN6RQ@mail.gmail.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>,
	Amir Vadai <amirv@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp07.au.ibm.com ([202.81.31.140]:38745 "EHLO
	e23smtp07.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752779AbaCYOG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 10:06:57 -0400
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Wed, 26 Mar 2014 00:06:54 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 8A4CD3578052
	for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 01:06:51 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2PE6bbN8716592
	for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 01:06:37 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2PE6osi006194
	for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 01:06:50 +1100
Content-Disposition: inline
In-Reply-To: <CAJZOPZLM+fRBqA_rkgiUO5FCd1YtzsCKN3=denHW6Tx7OHN6RQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 24, 2014 at 08:40:42AM +0200, Or Gerlitz wrote:
>On Mon, Mar 24, 2014 at 6:42 AM, Wei Yang <weiyang@linux.vnet.ibm.com> wrote:
>>
>> The second parameter of __mlx4_init_one() is used to identify whether the
>> pci_dev is a PF or VF. Currently, when it is invoked in mlx4_pci_slot_reset()
>> this information is missed.
>
>
>This patch isn't fixing something in 3.14, right? if this is the case
>I assume it's for net-next, please put a "net" or "net-next"
>indication (next-time)
>
>Or.

This one is deprecated, will send an updated version.

>
>>
>>
>> This patch passes the pci_dev_data to __mlx4_init_one().
>>
>> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>> ---
>>  drivers/net/ethernet/mellanox/mlx4/main.c |    8 +++++++-
>>  1 file changed, 7 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
>> index d711158..9ffce06 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
>> @@ -2670,7 +2670,13 @@ static pci_ers_result_t mlx4_pci_err_detected(struct pci_dev *pdev,
>>
>>  static pci_ers_result_t mlx4_pci_slot_reset(struct pci_dev *pdev)
>>  {
>> -       int ret = __mlx4_init_one(pdev, 0);
>> +       int ret;
>> +       struct mlx4_dev  *dev  = pci_get_drvdata(pdev);
>> +       struct mlx4_priv *priv = mlx4_priv(dev);
>> +       int               pci_dev_data;
>> +
>> +       pci_dev_data = priv->pci_dev_data;
>> +       ret = __mlx4_init_one(pdev, pci_dev_data);
>>
>>         return ret ? PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_RECOVERED;
>>  }
>> --
>> 1.7.9.5
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Richard Yang
Help you, Help me
