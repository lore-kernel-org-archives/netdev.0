From: Patrick McHardy <kaber@trash.net>
Subject: Re: tc filter add ... fw ... action drop
Date: Wed, 18 Jul 2007 12:29:46 +0200
Message-ID: <469DEB9A.9020606@trash.net>
References: <20070718032841.GA14874@toroid.org> <469DE243.20903@trash.net> <20070718102716.GA32421@toroid.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Abhijit Menon-Sen <ams@toroid.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34701 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758803AbXGRKaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 06:30:12 -0400
In-Reply-To: <20070718102716.GA32421@toroid.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Abhijit Menon-Sen wrote:
> At 2007-07-18 11:49:55 +0200, kaber@trash.net wrote:
> 
>>>  # tc filter add dev eth0 parent 1: protocol ip prio 0 handle
>>>    0xfffffff fw police rate 1 burst 1 mpu 0 mtu 1 action drop
>>
>>It seems this is merely a parsing error, iproute doesn't have an
>>"action" parameter and aborts parsing, so it uses the default
>>value of "RECLASSIFY".
> 
> 
> I can confirm that your patch deals with my command sensibly, and also
> that "tc filter add ... conform-exceed drop/drop" does what I wanted.
> 
> 
>>It never had this parameter [...]
> 
> 
> That command is from a script that used to work with iproute2-ss020116
> (2002!), which had the following in tc/m_police.c:
> 
> 210     } else if (strcmp(*argv, "action") == 0) {
> 211             NEXT_ARG();
> 212             if (get_police_result(&p.action, &presult, *argv)) {
> 
> I don't know when that bit was dropped, but it used to be there. :-)


Indeed, I missed that. I'll fix up the patch ..

