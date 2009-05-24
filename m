From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: regression: unregister_netdev() unusably slow
Date: Sun, 24 May 2009 23:42:17 +0200
Message-ID: <4A19BF39.4000305@cosmosbay.com>
References: <20090524192150.GE24757@kvack.org> <200905250023.31056.denys@visp.net.lb> <20090524213744.GG24757@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@lhnet.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:40412 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751720AbZEXVma convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 May 2009 17:42:30 -0400
In-Reply-To: <20090524213744.GG24757@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin LaHaise a =E9crit :
> On Mon, May 25, 2009 at 12:23:30AM +0300, Denys Fedoryschenko wrote:
>> Once oprofile gave me hint about similar issue
>=20
> I forgot to mention: there is no more than ~1% CPU usage while the in=
terfaces=20
> are being deleted.  I'm about half way through the bisect now and sho=
uld have=20
> the culprit soon.=20
>=20
> 		-ben

unregister a vlan here cost about 100 ms if CONFIG_NO_HZ is set, 50 ms =
if not set

(But vlan case might be litle bit more expensive than your case, since =
we call
synchronize_net() three times (once in unregister_vlan_dev(), and twice=
 in rollback_registered()


