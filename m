From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] tg3 locking update (with NAPI overtones)
Date: Tue, 26 Nov 2002 15:51:44 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021126.155144.43008660.davem@redhat.com>
References: <3DE406AE.2000908@pobox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <3DE406AE.2000908@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Looks good to me on first glance, testing will confirm
further :-)

Probably, to kill the long delays with locks held, we just
need to add a PHY config semaphore.  Interrupts that want to
try and program the PHY just do a down_trylock() on that semaphore
and defer their work if it cannot be acquired.
