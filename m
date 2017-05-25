From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net] sky2: Do not deadlock on sky2_hw_down
Date: Fri, 26 May 2017 00:05:20 +0200
Message-ID: <20170525220520.GA4706@electric-eye.fr.zoreil.com>
References: <20170524224353.124692-1-jemele@gmail.com>
 <20170525.134205.884395652948196578.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jemele@gmail.com, netdev@vger.kernel.org, jemele@google.com,
        mlindner@marvell.com, stephen@networkplumber.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170525.134205.884395652948196578.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> :
> From: Joshua Emele <jemele@gmail.com>
> Date: Wed, 24 May 2017 15:43:18 -0700
[...]
> > The sky2_hw_down uses sky2_tx_complete to free pending frames stuck in
> > the HW queue. Because sky2_hw_down can be called from a process context,
> > the call to u64_stats_update_begin can result in deadlock.
> > 
> > Because the statistics do not require update as part of the sky2_hw_down
> > sequence, prevent the update to avoid the deadlock.
> 
> I disagree.  Taking the interface down should cause events in the
> statistics to be lost.
>
> You're going to have to find a way to fix this without eliding
> the stats increments.

NAPI processing is already disabled at this stage in the device close()
path (and sky2_netpoll() uses napi_schedule).

It's possible to add a conditionnal bh or irq disabling instruction to
silent the warning but it should not be needed at all.

-- 
Ueimor
