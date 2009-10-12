From: Kevin Dawson <kevind@esi.com.au>
Subject: Re: [PATCH] ax25: unsigned cannot be less than 0 in ax25_ctl_ioctl()
Date: Tue, 13 Oct 2009 08:58:19 +1100
Message-ID: <4AD3A67B.6070703@cerebellum.kd>
References: <4AD0FB0B.8050609@gmail.com> <4AD34D3C.1060206@bfs.de> <4AD37D44.9050207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wharms@bfs.de, linux-hams@vger.kernel.org,
	netdev <netdev@vger.kernel.org>, Joerg Reuter <jreuter@yaina.de>,
	Andrew Morton <akpm@linux-foundation.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pecan.exetel.com.au ([220.233.0.17]:53125 "EHLO
	smtp.po.exetel.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752790AbZJLWYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 18:24:32 -0400
In-Reply-To: <4AD37D44.9050207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roel Kluin wrote:

>>  tmp_arg=ax25_ctl.arg * HZ;
>>
>>   if (arg == 0 || arg >  ULONG_MAX )
>> 		goto einval_put;
>
> I'm not sure, I think this would only work if we made `arg' an
> unsigned long long.

That depends on the possible values of ax25_ctl.arg.

> +	if (ax25_ctl.arg * HZ > ULONG_MAX && ax25_ctl.cmd != AX25_KILL)
> +		return -EINVAL;

Why the need to change arg before comparing it with a constant?  Let the 
compiler do the work:

	if (ax25_ctl.arg > ULONG_MAX / HZ && ...

Kevin
