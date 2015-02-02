From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] bluetooth: hci_sock: Use type cast "(void *)" to avoid
 building warnings
Date: Mon, 02 Feb 2015 12:39:58 -0800
Message-ID: <1422909598.30476.20.camel@perches.com>
References: <54CFE01D.5090309@sunrus.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Chen Gang S <gang.chen@sunrus.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0004.hostedemail.com ([216.40.44.4]:42615 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933243AbbBBUkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 15:40:03 -0500
In-Reply-To: <54CFE01D.5090309@sunrus.com.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-02-03 at 04:37 +0800, Chen Gang S wrote:
> The related warning (with allmodconfig under xtensa):
[]
> diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
[]
> @@ -952,7 +952,7 @@ static int hci_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
>  
>  		if (((ogf > HCI_SFLT_MAX_OGF) ||
>  		     !hci_test_bit(ocf & HCI_FLT_OCF_BITS,
> -				   &hci_sec_filter.ocf_mask[ogf])) &&
> +				   (void *)&hci_sec_filter.ocf_mask[ogf])) &&
>  		    !capable(CAP_NET_RAW)) {
>  			err = -EPERM;
>  			goto drop;

Probably better to change the hci_test_bit to take const void *

static inline int hci_test_bit(int nr, void *addr)
{
	return *((__u32 *) addr + (nr >> 5)) & ((__u32) 1 << (nr & 31));
}
