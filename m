From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH] LSM: Add post recvmsg() hook.
Date: Sun, 18 Jul 2010 19:49:11 +0900
Message-ID: <201007181949.IFC00070.OMHQVSFOLJFFOt@I-love.SAKURA.ne.jp>
References: <201007170114.GFC57373.SQJHOVtLFMOFFO@I-love.SAKURA.ne.jp>
	<20100716.123558.71592004.davem@davemloft.net>
	<201007171017.DFC73498.SFFFOMLVJOHOtQ@I-love.SAKURA.ne.jp>
	<1279441990.2476.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	paul.moore@hp.com, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:51550 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754181Ab0GRKtO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jul 2010 06:49:14 -0400
In-Reply-To: <1279441990.2476.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> I read this patch and could not find out if an SNMP counter was
> increased in the case a frame was not delivered but dropped in kernel
> land.

UDP_MIB_INDATAGRAMS and UDP_MIB_INERRORS will not be increased
if dropped by security_socket_post_recvmsg()'s decision.
Should we increment UDP_MIB_INDATAGRAMS and/or UDP_MIB_INERRORS?

udpInDatagrams
    "The total number of UDP datagrams delivered to UDP users."

udpNoPorts
    "The total number of received UDP datagrams for which there was no
     application at the destination port."

udpInErrors
    "The number of received UDP datagrams that could not be delivered for
     reasons other than the lack of an application at the destination port."
