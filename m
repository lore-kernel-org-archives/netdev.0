From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH 4/5] bonding: Added bond_tlb_xmit() for tlb mode.
Date: Mon, 31 Mar 2014 09:22:44 -0700
Message-ID: <1396282964.29410.53.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1396070947-17721-1-git-send-email-maheshb@google.com>
	 <1396281158.29410.41.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6ECFA7@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:48332 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753713AbaCaQWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 12:22:45 -0400
Received: by mail-pa0-f42.google.com with SMTP id fb1so8490646pad.1
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 09:22:45 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6ECFA7@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-31 at 16:00 +0000, David Laight wrote:

> Which may or not be faster...

We don't care of this kind of assertions.

Bring us real data, or just say nothing. This is a waste of time.

> As coded the case labels may be dense enough to generate a jump table.
> If byte reversed the generated code will be a branch tree.
> 
> A deep branch tree will be worse, a match on the first item of a branch
> tree will almost certainly be better.
> I'm not going to guess where the breakeven point is for any modern cpus.

This is ridiculous, there is no jumptable for ETH_P_IP, ETH_P_IPX,
ETH_P_IPV6.

Its not like their value will ever be 1 , 2 and 3

I suggest you take a look at the existing code in whole networking
stack. This is how we coded things, because there is no need to do
ntohs(variable) when we can simply write htons(constant) which even a
dumb compiler can understand. (We used to have __constant_htons() but it
looks its not needed these days.)
