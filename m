From: Craig Schlenter <craig@codefountain.com>
Subject: Re: [BUG KERNEL 2.6.20-rc1] ftp: get or put stops during file-transfer
Date: Thu, 4 Jan 2007 14:23:30 +0200
Message-ID: <20070104122330.GA2233@craigdell.detnet.com>
References: <20061230185043.d31d2104.komurojun-mbn@nifty.com> <20061230.102358.106876516.yoshfuji@linux-ipv6.org> <20061230205931.9e430173.komurojun-mbn@nifty.com> <20061230.231952.16573563.yoshfuji@linux-ipv6.org> <20070105054546.953196e5.komurojun-mbn@nifty.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>, bunk@stusta.de, jgarzik@pobox.com,
	viro@ftp.linux.org.uk, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from myw-stp-196-34-113-139.sentechsa.net ([196.34.113.139]:38333
	"EHLO craigdell.detnet.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S964814AbXADMdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jan 2007 07:33:43 -0500
To: Komuro <komurojun-mbn@nifty.com>
Content-Disposition: inline
In-Reply-To: <20070105054546.953196e5.komurojun-mbn@nifty.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 05, 2007 at 05:45:46AM +0900, Komuro wrote:
> Hi,
> 
> I made a patch below.
> With this patch, the ftp-transfer-stop problem does not happen.
> Therefore, I think this is not a problem of vsftpd.
> 
> Mr.YOSHIFUJI san, why did you set TCPOLEN_TSTAMP_ALIGNED
> to iov_len?
> 
> 
> 
> --- linux-2.6.20-rc3/net/ipv4/tcp_ipv4.c.orig	2007-01-03 11:50:04.000000000 +0900
> +++ linux-2.6.20-rc3/net/ipv4/tcp_ipv4.c	2007-01-03 15:30:44.000000000 +0900
> @@ -648,7 +648,7 @@ static void tcp_v4_send_ack(struct tcp_t
>  				   TCPOLEN_TIMESTAMP);
>  		rep.opt[1] = htonl(tcp_time_stamp);
>  		rep.opt[2] = htonl(ts);
> -		arg.iov[0].iov_len = TCPOLEN_TSTAMP_ALIGNED;
> +		arg.iov[0].iov_len = sizeof(rep);

Perhaps this was supposed to be
                arg.iov[0].iov_len += TCPOLEN_TSTAMP_ALIGNED;

That's what the ipv6 stuff does in places.

bye,

--Craig
