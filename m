From: Abhijit Menon-Sen <ams@toroid.org>
Subject: Re: tc filter add ... fw ... action drop
Date: Wed, 18 Jul 2007 15:57:16 +0530
Message-ID: <20070718102716.GA32421@toroid.org>
References: <20070718032841.GA14874@toroid.org> <469DE243.20903@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fugue.toroid.org ([85.10.196.113]:1844 "EHLO fugue.toroid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753333AbXGRK1S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2007 06:27:18 -0400
Content-Disposition: inline
In-Reply-To: <469DE243.20903@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At 2007-07-18 11:49:55 +0200, kaber@trash.net wrote:
>
> >   # tc filter add dev eth0 parent 1: protocol ip prio 0 handle
> >     0xfffffff fw police rate 1 burst 1 mpu 0 mtu 1 action drop
>
> It seems this is merely a parsing error, iproute doesn't have an
> "action" parameter and aborts parsing, so it uses the default
> value of "RECLASSIFY".

I can confirm that your patch deals with my command sensibly, and also
that "tc filter add ... conform-exceed drop/drop" does what I wanted.

> It never had this parameter [...]

That command is from a script that used to work with iproute2-ss020116
(2002!), which had the following in tc/m_police.c:

210     } else if (strcmp(*argv, "action") == 0) {
211             NEXT_ARG();
212             if (get_police_result(&p.action, &presult, *argv)) {

I don't know when that bit was dropped, but it used to be there. :-)

Thank you for your help.

-- ams
