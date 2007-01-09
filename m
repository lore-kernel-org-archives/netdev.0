From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [BUG KERNEL 2.6.20-rc1] ftp: get or put stops during
 file-transfer
Date: Tue, 09 Jan 2007 10:24:53 +0900 (JST)
Message-ID: <20070109.102453.32711440.yoshfuji@linux-ipv6.org>
References: <20061230.231952.16573563.yoshfuji@linux-ipv6.org>
	<20070105054546.953196e5.komurojun-mbn@nifty.com>
	<20070104122330.GA2233@craigdell.detnet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: komurojun-mbn@nifty.com, bunk@stusta.de, jgarzik@pobox.com,
	viro@ftp.linux.org.uk, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:45315 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881AbXAIBYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jan 2007 20:24:06 -0500
To: craig@codefountain.com
In-Reply-To: <20070104122330.GA2233@craigdell.detnet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070104122330.GA2233@craigdell.detnet.com> (at Thu, 4 Jan 2007 14:23:30 +0200), Craig Schlenter <craig@codefountain.com> says:

> On Fri, Jan 05, 2007 at 05:45:46AM +0900, Komuro wrote:
> > Hi,
> > 
> > I made a patch below.
> > With this patch, the ftp-transfer-stop problem does not happen.
> > Therefore, I think this is not a problem of vsftpd.
> > 
> > Mr.YOSHIFUJI san, why did you set TCPOLEN_TSTAMP_ALIGNED
> > to iov_len?
> > 
> > 
> > 
> > --- linux-2.6.20-rc3/net/ipv4/tcp_ipv4.c.orig	2007-01-03 11:50:04.000000000 +0900
> > +++ linux-2.6.20-rc3/net/ipv4/tcp_ipv4.c	2007-01-03 15:30:44.000000000 +0900
> > @@ -648,7 +648,7 @@ static void tcp_v4_send_ack(struct tcp_t
> >  				   TCPOLEN_TIMESTAMP);
> >  		rep.opt[1] = htonl(tcp_time_stamp);
> >  		rep.opt[2] = htonl(ts);
> > -		arg.iov[0].iov_len = TCPOLEN_TSTAMP_ALIGNED;
> > +		arg.iov[0].iov_len = sizeof(rep);
> 
> Perhaps this was supposed to be
>                 arg.iov[0].iov_len += TCPOLEN_TSTAMP_ALIGNED;
> 
> That's what the ipv6 stuff does in places.

Good catch! I agree.
Craig, please provide a patch for us, please.

Thank you again.

--yoshfuji
