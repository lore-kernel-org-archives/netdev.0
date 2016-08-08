From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: ipv6: Fix ping to link-local addresses.
Date: Mon, 08 Aug 2016 14:35:00 -0700 (PDT)
Message-ID: <20160808.143500.473355495580691289.davem@davemloft.net>
References: <1470642127-574-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org, ek@google.com,
	hideaki.yoshifuji@miraclelinux.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35455 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429AbcHHVfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 17:35:03 -0400
Received: by mail-pf0-f193.google.com with SMTP id h186so25582183pfg.2
        for <netdev@vger.kernel.org>; Mon, 08 Aug 2016 14:35:03 -0700 (PDT)
In-Reply-To: <1470642127-574-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Mon,  8 Aug 2016 16:42:07 +0900

> ping_v6_sendmsg never sets flowi6_oif, so it is not possible to
> ping an IPv6 address on a different interface. Instead, it sets
> flowi6_iif, which is incorrect but harmless. Also, it returns an
> error if a passed-in scope ID doesn't match sk_bound_dev_if.
> 
> Get rid of the error, stop setting flowi6_iif, and support
> various ways of setting oif in the same priority order used by
> udpv6_sendmsg.
> 
> Tested: https://android-review.googlesource.com/#/c/254470/
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

We should always give sk_bound_dev_if the highest priority.

Also, we should amend, not delete, the check against the scope
ID in the sockaddr.  As explained by YOSHIFUJI Hideaki.
