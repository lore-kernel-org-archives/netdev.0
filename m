From: ronny.hegewald@online.de
Subject: Aw: Re: question about checksumming and tcp_sendpage
Date: Fri, 6 Nov 2015 20:14:15 +0100
Message-ID: <trinity-afda3924-c5a6-4998-98b5-ee047f5cbe74-1446837255645@3capp-1and1-bs04>
References: <trinity-80ad84c3-456a-4f51-a3e9-afee4e8ae504-1446759288452@3capp-1and1-bs03>,
 <CALx6S369t4iOKYnM=Qzc-oguVZECK93=VJXbhzt+objjs70W4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: "Tom Herbert" <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.24]:63787 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284AbbKFTOR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 14:14:17 -0500
In-Reply-To: <CALx6S369t4iOKYnM=Qzc-oguVZECK93=VJXbhzt+objjs70W4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Well, looking at the code I don't readily see how this works either,
> but note that tcp_sendmsg has the same check also. If your analysis is
> correct then checksum for IPv6 would commonly be broken (i.e. several
> devices support IPv4 checksum but not IPv6)-- so I find that hard to
> believe so I'm probably missing something too! (at least this
> ambiguity is one more reason why we need to get rid of NETIF_F_IP_CSUM
> and NETIF_F_V6_CSUM!).

I think the checksum-building is not broken because of this on itself. The
problem i see is for example in case pages are sent from a block-device 
over the net. 

Depending on the block-device this pages might be changed at any time. 
Because of the described issue the page-data wouldn't be copied as a call 
to sock_no_sendpage would do it. So the page-data might change at any time
during or after the checksum-building. From my understanding this would just
cause a crc-error anytime after sending and would only lead to a resent 
of the data, probably with a new checksum which will then be correct So
there wouldn't be a obvious impact except some bad tcp packages.

> Can you try to verify this a bug with some testing?

Will do.
