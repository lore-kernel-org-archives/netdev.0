From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net] bonding: reset the slave's mtu when its be changed
Date: Fri, 10 Jan 2014 22:41:48 +0300
Message-ID: <52D04CFC.9060701@cogentembedded.com>
References: <52CFDA63.8070601@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:37540 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855AbaAJSlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 13:41:46 -0500
Received: by mail-lb0-f178.google.com with SMTP id c11so3589176lbj.23
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 10:41:44 -0800 (PST)
In-Reply-To: <52CFDA63.8070601@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/10/2014 02:32 PM, Ding Tianhong wrote:

> All slave should have the same mtu with mastet's, and the bond do it when

    Only "master", already noted by Dave.

> enslave the slave, but the user could change the slave's mtu, it will cause
> the master and slave have different mtu, althrough in AB mode, it does not

    Only "although".

> matter if the slave is not the current slave, but in other mode, it is incorrect,
> so reset the slave's mtu like the master set.

> Cc: Jay Vosburgh <fubar@us.ibm.com>
> Cc: Veaceslav Falico <vfalico@redhat.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
> ---
>   drivers/net/bonding/bond_main.c | 21 ++++++++++-----------
>   1 file changed, 10 insertions(+), 11 deletions(-)

> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 398e299..e7b5bcf 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -2882,18 +2882,17 @@ static int bond_slave_netdev_event(unsigned long event,
>   		 */
>   		break;
>   	case NETDEV_CHANGEMTU:
> -		/*
> -		 * TODO: Should slaves be allowed to
> -		 * independently alter their MTU?  For
> -		 * an active-backup bond, slaves need
> -		 * not be the same type of device, so
> -		 * MTUs may vary.  For other modes,
> -		 * slaves arguably should have the
> -		 * same MTUs. To do this, we'd need to
> -		 * take over the slave's change_mtu
> -		 * function for the duration of their
> -		 * servitude.
> +		/* All slave should have the same mtu
> +		 * as master.
>   		 */
> +		if (slave->dev->mtu != bond->dev->mtu) {
> +			int res;

    Please insert empty line after declaration.

> +			slave->original_mtu = slave->dev->mtu;
> +			res = dev_set_mtu(slave->dev, bond->dev->mtu);
> +			if (res)
> +				pr_debug("Error %d calling dev_set_mtu for slave %s\n",
> +					 res, slave->dev->name);

    {} wouldn't hurt around multi-line *if* arm.

> +		}
>   		break;
>   	case NETDEV_CHANGENAME:
>   		/*

WBR, Sergei
