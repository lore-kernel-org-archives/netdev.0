From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] net: solve a NAPI race
Date: Mon, 27 Feb 2017 09:10:34 -0800
Message-ID: <1488215434.9415.200.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1488032577.9415.131.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488166294.9415.172.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488205298.9415.180.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170227.111944.1725806340309799464.davem@davemloft.net>
         <1488213854.9415.198.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com, saeedm@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:32860 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751760AbdB0Rej (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 12:34:39 -0500
Received: by mail-pg0-f65.google.com with SMTP id x17so1695959pgi.0
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 09:34:38 -0800 (PST)
In-Reply-To: <1488213854.9415.198.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-02-27 at 08:44 -0800, Eric Dumazet wrote:

> // busy polling or napi_watchdog()

BTW, we also can add to the beginning of busy_poll_stop() :

clear_bit(NAPI_STATE_MISSED, &napi->state);
