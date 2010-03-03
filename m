From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH 8/8] x25: use limited socket backlog
Date: Wed, 03 Mar 2010 15:33:01 +0100
Message-ID: <1267626781.2997.28.camel@edumazet-laptop>
References: <1267598111-12503-1-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-2-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-3-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-4-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-5-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-6-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-7-git-send-email-yi.zhu@intel.com>
	 <1267598111-12503-8-git-send-email-yi.zhu@intel.com>
	 <1267600109.2839.101.camel@edumazet-laptop>
	 <d45a3acc1003030338m3102a95p1b06b7db1b24e58e@mail.gmail.com>
	 <DA586906BA1FFC4384FCFD6429ECE860A45A6992@shzsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: andrew hendry <andrew.hendry@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Zhu, Yi" <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:39819 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754335Ab0CCOdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 09:33:09 -0500
Received: by bwz1 with SMTP id 1so49718bwz.21
        for <netdev@vger.kernel.org>; Wed, 03 Mar 2010 06:33:07 -0800 (PST)
In-Reply-To: <DA586906BA1FFC4384FCFD6429ECE860A45A6992@shzsmsx502.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 03 mars 2010 =C3=A0 22:00 +0800, Zhu, Yi a =C3=A9crit :
> andrew hendry <andrew.hendry@gmail.com> wrote:
>=20
> > Will wait for the next spin and in the meantime think if there is w=
ay
> > to test it. x25 with no loopback and being so slow probably cant ge=
nerate the same
> > as your UDP case.
>=20
> I didn't find a way to drop the packet correctly. So I didn't change =
any behavior in
> this patch. Nor did I do in the second spin. It will be fine if you a=
lso think x25 doesn't
> need to limit its backlog size.

So are we sure we cant flood X25 backlog, using X25 over IP ?

You discovered a _fatal_ flaw in backlog processing, we should close al=
l
holes, not only UDP case. You can be sure many bad guys will inspect al=
l
possibilities to bring down Linux hosts.

If you feel uncomfortable with a small limit, just stick a big one, lik=
e
256 packets, and you are 100% sure you wont break a protocol. If this
limit happens to be too small, we can change it later.

(No need to count bytes, since truesize includes kernel overhead, and
this overhead depends on 32/64 wide of host and kernel versions)


