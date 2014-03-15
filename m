From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 09/16] sky2: Don't receive packets when the
 napi budget == 0
Date: Fri, 14 Mar 2014 18:34:36 -0700
Message-ID: <20140314183436.6638068a@nehalam.linuxnetplumber.net>
References: <87a9cxf7mp.fsf_-_@xmission.com>
	<20140311.124907.1180556684992271103.davem@davemloft.net>
	<87wqg0cy9d.fsf@xmission.com>
	<20140311.160931.1395978386605601765.davem@davemloft.net>
	<877g808luk.fsf_-_@xmission.com>
	<871ty41dps.fsf_-_@xmission.com>
	<87mwgsxodl.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: ebiederm@xmission.com (Eric W. Biederman)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:46930 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754170AbaCOBej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 21:34:39 -0400
Received: by mail-pb0-f49.google.com with SMTP id jt11so3316321pbb.36
        for <netdev@vger.kernel.org>; Fri, 14 Mar 2014 18:34:39 -0700 (PDT)
In-Reply-To: <87mwgsxodl.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Mar 2014 18:05:26 -0700
ebiederm@xmission.com (Eric W. Biederman) wrote:

> 
> Processing any incoming packets with a with a napi budget of 0
> is incorrect driver behavior.
> 
> This matters as netpoll will shortly call drivers with a budget of 0
> to avoid receive packet processing happening in hard irq context.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
>  drivers/net/ethernet/marvell/sky2.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
> index 2434611d1b4e..0ddfc43069ba 100644
> --- a/drivers/net/ethernet/marvell/sky2.c
> +++ b/drivers/net/ethernet/marvell/sky2.c
> @@ -2735,6 +2735,9 @@ static int sky2_status_intr(struct sky2_hw *hw, int to_do, u16 idx)
>  	unsigned int total_bytes[2] = { 0 };
>  	unsigned int total_packets[2] = { 0 };
>  
> +	if (to_do <= 0)
> +		return work_done;
> +
>  	rmb();
>  	do {
>  		struct sky2_port *sky2;


I am fine with this.

Really should change to_do to an unsigned but that is another
battle.
