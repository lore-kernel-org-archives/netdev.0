From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Wed, 18 Nov 2015 19:47:21 +0900
Message-ID: <CAKD1Yr0Gpr6Ex2i1TXEWyETn48P4g5vBvFZ9=_g+Lz_7-PqBDQ@mail.gmail.com>
References: <1447811024-8553-1-git-send-email-lorenzo@google.com>
 <20151117192738.365145d7@samsung9> <1447819493.22599.137.camel@edumazet-glaptop2.roam.corp.google.com>
 <1447841988.834928.443071345.1AAFF2A9@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, Erik Kline <ek@google.com>,
	=?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:36496 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843AbbKRKrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 05:47:42 -0500
Received: by ykdr82 with SMTP id r82so55819288ykd.3
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 02:47:41 -0800 (PST)
In-Reply-To: <1447841988.834928.443071345.1AAFF2A9@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 18, 2015 at 7:19 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> I bet there will soon be a timewaitd which handles the not configurable
> (David has rejected all those patches so far) timeout of TIME_WAIT
> sockets. And I bet it will be used. :/

No, SOCK_DESTROY has no effect on TCP_TIME_WAIT sockets or any other
non-full socket.

When called on any socket where sk_fullsock(sk) is false, it returns
EOPNOTSUPP because there is nothing to do. Its purpose is to interrupt
blocked userspace socket calls, not to release resources.
