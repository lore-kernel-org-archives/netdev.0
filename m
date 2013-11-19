From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] ipv6: use sk_v6_copy_addrs when memcpy struct
 ipv6_pinfo
Date: Tue, 19 Nov 2013 06:23:21 -0800
Message-ID: <1384871001.8604.103.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384829247-8624-1-git-send-email-wangweidong1@huawei.com>
	  <1384829247-8624-3-git-send-email-wangweidong1@huawei.com>
	  <20131119031408.GQ16541@order.stressinduktion.org>
	  <528ADBDD.9040209@huawei.com>
	  <1384833538.8604.83.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1384833653.8604.84.camel@edumazet-glaptop2.roam.corp.google.com>
	 <528B4D0B.10204@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: wangweidong <wangweidong1@huawei.com>, davem@davemloft.net,
	gerrit@erg.abdn.ac.uk, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, vyasevich@gmail.com,
	nhorman@tuxdriver.com, dccp@vger.kernel.org,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	dingtianhong@huawei.com
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:39866 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752729Ab3KSOXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 09:23:17 -0500
In-Reply-To: <528B4D0B.10204@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-11-19 at 12:35 +0100, Daniel Borkmann wrote:
> On 11/19/2013 05:00 AM, Eric Dumazet wrote:
> > On Mon, 2013-11-18 at 19:58 -0800, Eric Dumazet wrote:
> >
> >> But sctp is not tcp ;)
> >>
> >> sctp_copy_sock() is doing some clever/partial copy of the socket, so
> >> please fix it ;)
> >>
> >> No idea why it's not doing the normal copy of the socket.
> >
> > BTW, not doing the full copy means for example that SO_MAX_PACING_RATE
> > is broken for SCTP.
> 
> Yep, indeed. Looking into it ...

It might be the time to finally use inet_csk_clone_lock() in SCTP.
