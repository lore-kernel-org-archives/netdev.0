From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: change capability used by socket options
 IP{,V6}_TRANSPARENT
Date: Wed, 19 Oct 2011 19:34:35 -0400 (EDT)
Message-ID: <20111019.193435.1214580639401316303.davem@davemloft.net>
References: <20110920.154213.888729603269720228.davem@redhat.com>
	<1318889783-23183-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: maze@google.com, netdev@vger.kernel.org, bazsi@balabit.hu
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51602 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750870Ab1JSXen convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 19:34:43 -0400
In-Reply-To: <1318889783-23183-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Mon, 17 Oct 2011 15:16:23 -0700

> From: Maciej =AFenczykowski <maze@google.com>
>=20
> Up till now the IP{,V6}_TRANSPARENT socket options (which actually se=
t
> the same bit in the socket struct) have required CAP_NET_ADMIN
> privileges to set or clear the option.
>=20
> - we make clearing the bit not require any privileges.
> - we deprecate using CAP_NET_ADMIN for this purpose.
> - we allow CAP_NET_RAW to set this bit, because raw
>   sockets already effectively allow you to emulate socket
>   transparency.
> - we print a warning (but allow it) if you try to set the socket
>   option with CAP_NET_ADMIN privs, but without CAP_NET_RAW.
>=20
> Signed-off-by: Maciej =AFenczykowski <maze@google.com>

Warnings for something that has worked ever since the feature was
added, and in fact was the only way to make use of the feature, is
terrible.

You must support the status quo forever or else you risk breaking
existing setups.  So the warning is pointless, you'll never be
able to remove CAP_NET_ADMIN from these code paths, so there is
zero value in warning about it because we'll never change this.

I'm disliking these changes more and more.  I refuse to apply this
patch.
