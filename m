From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 42809] New: kernel panic when receiving an ipsec packet
Date: Thu, 23 Feb 2012 02:54:39 +0100
Message-ID: <1329962079.15610.6.camel@edumazet-laptop>
References: <bug-42809-100@https.bugzilla.kernel.org/>
	 <20120222092056.5fca788b@nehalam.linuxnetplumber.net>
	 <4F4528CE.7080702@linuxsystems.it> <4F458F82.3060808@linuxsystems.it>
	 <1329961083.15610.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>, openadsl-users@lists.sourceforge.net,
	openadsl-devel@lists.sourceforge.net, support@traverse.com.au,
	support@rocksolidelectronics.com, 660804@bugs.debian.org
To: =?ISO-8859-1?Q?Niccol=F2?= Belli <darkbasic@linuxsystems.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:50735 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855Ab2BWByq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 20:54:46 -0500
Received: by wics10 with SMTP id s10so433627wic.19
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2012 17:54:44 -0800 (PST)
In-Reply-To: <1329961083.15610.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 23 f=C3=A9vrier 2012 =C3=A0 02:38 +0100, Eric Dumazet a =C3=A9=
crit :

> Which driver handles this Traverse Solos card ?

If br2684_push() is used, it seems it lacks proper call to
skb_reset_mac_header(skb) in paths where eth_type_trans() is not called=
=2E

Later in xfrm4_mode_tunnel_input() we crash because we assume
skb_mac_header() is valid.
