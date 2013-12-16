From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 1/4] tipc: remove unnecessary variables and conditions
Date: Mon, 16 Dec 2013 13:33:18 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7496@saturn3.aculab.com>
References: <1387197631-17240-1-git-send-email-wangweidong1@huawei.com> <1387197631-17240-2-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <erik.hugne@ericsson.com>, <maloy@donjonn.com>,
	<netdev@vger.kernel.org>
To: "Wang Weidong" <wangweidong1@huawei.com>, <jon.maloy@ericsson.com>,
	<allan.stephens@windriver.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:41727 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754124Ab3LPNej convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 08:34:39 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 06420-03 for <netdev@vger.kernel.org>;
 Mon, 16 Dec 2013 13:34:37 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1387197631-17240-2-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Wang Weidong
> Sent: 16 December 2013 12:40
> We remove a number of unnecessary variables and branches
> in TIPC. This patch is cosmetic and does not change the
> operation of TIPC in any way.
> 
...
>  int __tipc_disconnect(struct tipc_port *tp_ptr)
>  {
> -	int res;
> -
>  	if (tp_ptr->connected) {
>  		tp_ptr->connected = 0;
>  		/* let timer expire on it's own to avoid deadlock! */
>  		tipc_nodesub_unsubscribe(&tp_ptr->subscription);
> -		res = 0;
> -	} else {
> -		res = -ENOTCONN;
> +		return 0;
>  	}
> -	return res;
> +
> +	return -ENOTCONN;
>  }

IMHO better coded as:

	if (!tp_ptr->connected)
		return -ENOTCON;

	tp_ptr->connected = 0;
	/* let timer expire on it's own to avoid deadlock! */
	tipc_nodesub_unsubscribe(&tp_ptr->subscription);
	return 0;

	David

	
