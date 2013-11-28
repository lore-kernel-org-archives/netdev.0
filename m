From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net] diag: fix netlink API attributes
Date: Thu, 28 Nov 2013 22:19:16 +0000
Message-ID: <20131128221916.GB4100@casper.infradead.org>
References: <1385647039-1547-1-git-send-email-nicolas.dichtel@6wind.com>
 <20131128163816.GA32047@casper.infradead.org>
 <52977F44.6070002@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:60578 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001Ab3K1WTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 17:19:17 -0500
Content-Disposition: inline
In-Reply-To: <52977F44.6070002@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/13 at 06:37pm, Nicolas Dichtel wrote:
> Le 28/11/2013 17:38, Thomas Graf a =E9crit :
> >On 11/28/13 at 02:57pm, Nicolas Dichtel wrote:
> >>The first netlink attribute (value 0) must always be defined as non=
e/unspec.
> >>This is correctly done in inet_diag.h, but other diag interfaces ar=
e broken.
> >>
> >>Libraries like libnl skip this kind of attributes, thus it's never =
reported to
> >>the application.
> >>
> >>CC: Thomas Graf <tgraf@suug.ch>
> >>Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> >
> >First of all, thanks for the notification Nicolas. I'll fix libnl to
> >pass through these attributes.
> Fine :)
> Thank you!

=46ixed in:

commit 6a8d90f5fec48b6e376ff29ccf3e0c620a41e758
Author: Thomas Graf <tgraf@suug.ch>
Date:   Thu Nov 28 23:14:38 2013 +0100

    attr: Allow attribute type 0

    {netlink,packet,unix}_diag use attribute type 0 for valid
    attributes. The value was reserved and usage was prohibited
    by the protocol but we can't undo the breakge.
   =20
    Make libnl accept attribute type 0 to allow parsing these
    attributes.
   =20
    Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
    Signed-off-by: Thomas Graf <tgraf@suug.ch>

> >I think the fix you propose is no an option as it breaks backwards
> >compatiblity with existing user space. We cannot change the value
> >of existing attributes.
> Yes, I was just wondering how to fix it.
> It also breaks the patch you've proposed in this thread:
> http://thread.gmane.org/gmane.linux.network/251478/focus=3D252764
>=20
> Hence, aligning attributes on 64-bits is still unresolved :(

Unfortunately I ran into other places where an attribute type 0
was used. Therefore the idea of using NLA_UNSPEC (0) to insert
padding attributes doesn't work. We would need to find another
way to insert padding. I'll be glad to share the WIP patch if
somebody else would like to continue the work.
