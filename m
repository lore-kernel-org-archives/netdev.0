From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH net-next] Performance improvements for socket/close and accept/close.
Date: Mon, 9 Mar 2015 14:14:56 -0700
Message-ID: <CAHo-OozBxw=h--dSjhobVfepC_10=H5_9DvXEvrhtnrFvc5tdw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Theodore Ts'o" <tytso@mit.edu>,
	Linux NetDev <netdev@vger.kernel.org>
To: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:46546 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753123AbbCIVO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 17:14:58 -0400
Received: by lbiz11 with SMTP id z11so48185081lbi.13
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 14:14:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently socket/close and accept/close require the acquisition of the
files lock 3 times
(twice in socket/accept, once in close), this patch series cuts this down to 2.

net-next performance on dual socket, 8 cores per socket, 2 HTs per
core, i.e. 32 hyperthreaded intel x86_64 machine:

prior to patch series:

843780 socket/close per sec (single thread)
629763 socket/close per sec (32 threaded process)

after patch series:

856149 socket/close per sec (single thread)
763282 socket/close per sec (32 threaded process)

- Maciej
