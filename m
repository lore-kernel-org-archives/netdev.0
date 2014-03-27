From: Wei Yang <weiyang@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next resend] net/mlx4_core: pass
 pci_device_id.driver_data to __mlx4_init_one during reset
Date: Thu, 27 Mar 2014 09:18:29 +0800
Message-ID: <20140327011829.GA4559@richard>
References: <1395828952-11471-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <5332DDF3.2040703@cogentembedded.com>
Reply-To: Wei Yang <weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yang <weiyang@linux.vnet.ibm.com>, jackm@dev.mellanox.co.il,
	ogerlitz@mellanox.com, davem@davemloft.net, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([122.248.162.4]:51984 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194AbaC0BSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 21:18:40 -0400
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <weiyang@linux.vnet.ibm.com>;
	Thu, 27 Mar 2014 06:48:37 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 082D0E0045
	for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 06:52:33 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2R1IGjg197098
	for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 06:48:17 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2R1IVrK022131
	for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 06:48:31 +0530
Content-Disposition: inline
In-Reply-To: <5332DDF3.2040703@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2014 at 06:02:27PM +0400, Sergei Shtylyov wrote:
>Hello.
>
>On 26-03-2014 14:15, Wei Yang wrote:
>
>>[Note: seems my network/mail system got some problem yesterday. Resend it in
>>case it is lost. If you have already got one, please ignore it.]
>
>   Put such remarks under --- tear line in the future, so that David
>don't have to edit them out when applying.

Thanks, first time I got this tip. Will do this next time :-)

>
>>The second parameter of __mlx4_init_one() is used to identify whether the
>>pci_dev is a PF or VF. Currently, when it is invoked in mlx4_pci_slot_reset()
>>this information is missed.
>
>>This patch match the pci_dev with mlx4_pci_table and passes the
>>pci_device_id.driver_data to __mlx4_init_one() in mlx4_pci_slot_reset().
>
>>Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
>>---
>>  drivers/net/ethernet/mellanox/mlx4/main.c |    6 +++++-
>>  1 file changed, 5 insertions(+), 1 deletion(-)
>
>>diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
>>index d711158..b083808 100644
>>--- a/drivers/net/ethernet/mellanox/mlx4/main.c
>>+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
>>@@ -2670,7 +2670,11 @@ static pci_ers_result_t mlx4_pci_err_detected(struct pci_dev *pdev,
>>
>>  static pci_ers_result_t mlx4_pci_slot_reset(struct pci_dev *pdev)
>>  {
>>-	int ret = __mlx4_init_one(pdev, 0);
>>+	const struct pci_device_id*  id;
>
>   * should be close to 'id' and one space is enough. I guess you
>haven't run your patch thru scripts/checkpatch.pl?

Oops, my bad. Will fix it.

>
>WBR, Sergei

-- 
Richard Yang
Help you, Help me
