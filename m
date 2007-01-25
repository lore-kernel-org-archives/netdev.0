From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address
 Detection
Date: Thu, 25 Jan 2007 17:34:10 -0500
Message-ID: <45B93062.7060101@hp.com>
References: <20070119212314.GA10748@hmsreliant.homelinux.net> <20070120.080507.25118874.yoshfuji@linux-ipv6.org> <20070122181528.GD21059@hmsreliant.homelinux.net> <20070123.091820.104515696.yoshfuji@linux-ipv6.org> <20070123205118.GC582@hmsreliant.homelinux.net> <1169690087.23312.7.camel@w-sridhar2.beaverton.ibm.com> <20070125133340.GA8891@hmsreliant.homelinux.net> <45B8E60B.7080809@hp.com> <20070125194500.GB8891@hmsreliant.homelinux.net> <45B910B3.5000809@hp.com> <20070125212651.GB12136@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	=?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kg?=
	 =?UTF-8?B?LyDlkInol6Toi7HmmI4=?= <yoshfuji@linux-ipv6.org>,
	davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, kaber@coreworks.de, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:51414 "EHLO atlrel9.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030641AbXAYWeO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jan 2007 17:34:14 -0500
In-Reply-To: <20070125212651.GB12136@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Neil

I went through the RFC again it seems like the following is missing:

Section 3.3:

> * (modifies section 5.4.2) The host MUST join the all-nodes multicast
>    address and the solicited-node multicast address of the
>    Tentative address.  The host SHOULD NOT delay before sending
>    Neighbor Solicitation messages.

For this, addrconf_dad_kick() should pass 0 to addrconf_mod_timer
when the address is optimistic.  Otherwise, we'll delay DAD some of
the purpose of optimistic addresses is lost.

-vlad
