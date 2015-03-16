From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] ss: better 32bit support
Date: Mon, 16 Mar 2015 11:29:14 -0700
Message-ID: <1426530554.11398.219.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426006607.11398.5.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1426360760.4173.101.camel@decadent.org.uk>
	 <063D6719AE5E284EB5DD2968C1650D6D1CB017F6@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Ben Hutchings' <ben@decadent.org.uk>,
	Stephen Hemminger <shemming@brocade.com>,
	netdev <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:37757 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933967AbbCPS3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 14:29:16 -0400
Received: by igcqo1 with SMTP id qo1so50699488igc.0
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 11:29:16 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB017F6@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-16 at 16:39 +0000, David Laight wrote:

> I wondered if the code should be reading the value in the host's natural
> endianness?
> Then the code might be optimisable to:
> 	return *(unsigned long long *)cookie;

This will trap on arches requesting 8 bytes alignment.

Not all linux hosts run x86

Look at rta_getattr_u64(), and you'll see that manipulating 64bit values
in netlink requires a memcpy() because we have no 64bit alignment
guarantee.

> which rather begs the question as to why cookie is uint32_t[2] instead of
> uint64_t.
> 

This question comes too late, inet_diag was added years ago,
and we must keep ABI compatibility forever.
