From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-2.6] bonding: fix rx_handler locking
Date: Wed, 23 Mar 2011 20:25:37 +0100
Message-ID: <4D8A4931.10903@gmail.com>
References: <1300797492-16128-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	fubar@us.ibm.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52322 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756578Ab1CWTZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 15:25:41 -0400
Received: by wwa36 with SMTP id 36so10520291wwa.1
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2011 12:25:40 -0700 (PDT)
In-Reply-To: <1300797492-16128-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/03/2011 13:38, Jiri Pirko a =C3=A9crit :
> This prevents possible race between bond_enslave and bond_handle_fram=
e
> as reported by Nicolas by moving rx_handler register/unregister.
> slave->bond is added to hold pointer to master bonding sructure. That
> way dev->master is no longer used in bond_handler_frame.
> Also, this removes "BUG: scheduling while atomic" message
>
> Reported-by: Nicolas de Peslo=C3=BCan<nicolas.2p.debian@gmail.com>
> Signed-off-by: Jiri Pirko<jpirko@redhat.com>

Thanks Jiri, it works.

Tested-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>

Regarding the code review, can you explain the reasons why you apparent=
ly duplicated the fields=20
related to the slave/master relationship?

Do you plan to totally remove dev->master usage in bonding in a follow-=
up patch?

	Nicolas.
