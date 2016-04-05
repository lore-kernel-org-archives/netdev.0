From: Johannes Berg <johannes@sipsolutions.net>
Subject: NETLINK_URELEASE non-bound socket problem (was: [PATCH] Fix local
 DoS in cfg80211 subsystem)
Date: Tue, 05 Apr 2016 11:56:28 +0200
Message-ID: <1459850188.18188.38.camel@sipsolutions.net>
References: <CAFSVvRfjZszSfovXZ0piPqOgVKH=10sG7pvnvkoWJChL38ifqQ@mail.gmail.com>
	 (sfid-20160404_171731_309095_517B9817)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, samuel <samuel@sortiz.org>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>
To: Dmitrijs Ivanovs <dmitrijs.ivanovs@ubnt.com>,
	linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:53660 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757103AbcDEJ4c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 05:56:32 -0400
In-Reply-To: <CAFSVvRfjZszSfovXZ0piPqOgVKH=10sG7pvnvkoWJChL38ifqQ@mail.gmail.com> (sfid-20160404_171731_309095_517B9817)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dmitrijs,

Thanks for reporting this problem.

> The patch below corrects this problem in kernel space. 

I don't think that this is correct, there are four more users of
NETLINK_URELEASE (nfnetlink, NFC), and afaict all of them have the same
bug as nl80211.

Rather than fix all of them, I think we should simply not report
NETLINK_URELEASE for netlink sockets that weren't bound; if any user
comes up that requires them later we could add a new event instead.

I can't find what commit introduced this code, it goes back before git
history, so I don't have the commit log. Maybe it was done for
nfnetlink log/queue? Certainly both nl80211 and NFC are much newer.

> Also, it is
> recommended to ensure that user-space applications are not using
> user-supplied port_id for netlink sockets (which is default in
> libnl-tiny for example).

This I think we should remove from the commit log - it's misleading and
there's no point.

johannes
