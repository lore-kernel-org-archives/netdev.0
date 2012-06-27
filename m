From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-next] udp: Add socket early demux support
Date: Wed, 27 Jun 2012 10:29:19 +0800
Message-ID: <CABa6K_G1+7xvPkveRWEWCpAJcf8gK4=zKwXGtOxJLW2wTCCvMA@mail.gmail.com>
References: <1340739826-3363-1-git-send-email-subramanian.vijay@gmail.com> <20120626.143401.445148198931339546.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: subramanian.vijay@gmail.com, netdev@vger.kernel.org,
	shemminger@vyatta.com, eric.dumazet@gmail.com,
	alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:43171 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159Ab2F0C3k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 22:29:40 -0400
Received: by qcmt36 with SMTP id t36so379360qcm.1
        for <netdev@vger.kernel.org>; Tue, 26 Jun 2012 19:29:39 -0700 (PDT)
In-Reply-To: <20120626.143401.445148198931339546.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 27, 2012 at 5:34 AM, David Miller <davem@davemloft.net> wro=
te:
>
> You can't do this.
>
> If the UDP socket has wildcards, that means the source address of the
> route will not be validated. =A0This means we will start accepting
> spoofed packets. =A0It also means the route you are caching is going
> to be the wrong route since the keys are variable.
>
> You can only do an early demux where all the keys are fully specified
> and there are no wildcards. =A0That why for TCP we only early demux f=
or
> established sockets.

How about implementing the whole early demux infrastructure on
iptables/netfilter like rpfilter and TPROXY, then users have more
controls.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
