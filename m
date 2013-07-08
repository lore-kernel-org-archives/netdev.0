From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Extremely bad performance with RTL8111/8168B
Date: Tue, 9 Jul 2013 00:01:49 +0200
Message-ID: <20130708220149.GA15766@electric-eye.fr.zoreil.com>
References: <20130708095459.GA29788@amd.pavel.ucw.cz>
 <1373291269.4979.102.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Machek <pavel@ucw.cz>, Hayes Wang <hayeswang@realtek.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38546 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322Ab3GHWB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 18:01:59 -0400
Content-Disposition: inline
In-Reply-To: <1373291269.4979.102.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> :
[8168d failure]
> It looks like TSO packets are not transmitted, so TCP only 'works'
> because retransmits use non TSO packets.
> 
> Could you report "ethtool -k eth0" ?
> 
> try : ethtool -K eth0 tso off

If so it could be worth adding a test for RTL_GIGA_MAC_VER_25 in
rtl_test_hw_pad_bug as has been done for RTL_GIGA_MAC_VER_34 (see
b423e9ae49d78ea3f53b131c8d5a6087aed16fd6).

1a9646497b163a8b9da5e70008d809dc91b32855 may be reverted if
'ethtool -K eth0 tso off' does not make a difference.

-- 
Ueimor
