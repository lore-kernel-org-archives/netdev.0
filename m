From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/4] scsi_tcp: block BH in TCP callbacks
Date: Wed, 18 May 2016 10:29:25 -0700
Message-ID: <1463592565.18194.137.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463532249-20850-1-git-send-email-edumazet@google.com>
	 <1463532249-20850-2-git-send-email-edumazet@google.com>
	 <573CA47F.10304@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Venkatesh Srinivas <venkateshs@google.com>
To: Mike Christie <michaelc@cs.wisc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33863 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932559AbcERR32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 13:29:28 -0400
Received: by mail-pf0-f196.google.com with SMTP id 145so5606869pfz.1
        for <netdev@vger.kernel.org>; Wed, 18 May 2016 10:29:27 -0700 (PDT)
In-Reply-To: <573CA47F.10304@cs.wisc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-05-18 at 12:21 -0500, Mike Christie wrote:

> Can I just confirm that nested bh lock calls like:
> 
> spin_lock_bh(lock1);
> spin_lock_bh(lock2);
> 
> do something
> 
> spin_unlock_bh(lock2);
> spin_unlock_bh(lock1);
> 
> is ok? It seems smatch sometimes warns about this.

It is ok.

More generally

local_bh_disable();
local_bh_disable();

..

local_bh_enable();
local_bh_enable();

is ok, we already have a lot of them.
