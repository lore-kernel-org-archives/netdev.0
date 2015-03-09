From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/8] net/socket: sys_accept4 - reverse allocation order
Date: Mon, 09 Mar 2015 15:11:06 -0700
Message-ID: <1425939066.8261.18.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAHo-OozBxw=h--dSjhobVfepC_10=H5_9DvXEvrhtnrFvc5tdw@mail.gmail.com>
	 <1425936003-24544-1-git-send-email-zenczykowski@gmail.com>
	 <1425936003-24544-4-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Theodore Ts'o <tytso@mit.edu>, netdev@vger.kernel.org
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:37958 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753668AbbCIWLI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 18:11:08 -0400
Received: by igbhl2 with SMTP id hl2so25287550igb.3
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 15:11:07 -0700 (PDT)
In-Reply-To: <1425936003-24544-4-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-03-09 at 14:19 -0700, Maciej =C5=BBenczykowski wrote:
> From: Maciej =C5=BBenczykowski <maze@google.com>
>=20
> Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
> ---

Unfortunately this changes accept() behavior when/if ENFILE/EMFILE is
reported.

Some applications might depend on this behavior to eventually start a
garbage collection of a cache using file descriptors to regular files.

After your patch, a failed accept() call would silently 'consume' a
session in the listener queue.

Also, this patch series should be CCed to lkml and Al Viro, as it is a
mix of fs & network changes.
