From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] xen-netfront: Delete rx_refill_timer in
 xennet_disconnect_backend()
Date: Mon, 30 Jan 2017 11:06:49 -0800
Message-ID: <1485803209.6360.111.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485798346-4425-1-git-send-email-boris.ostrovsky@oracle.com>
         <1485799651.6360.101.camel@edumazet-glaptop3.roam.corp.google.com>
         <40057d9d-c615-1a2b-63a2-ab717c29d659@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jgross@suse.com, xen-devel@lists.xenproject.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        vineethp@amazon.com, wei.liu2@citrix.com, paul.durrant@citrix.com,
        stable@vger.kernel.org
To: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <40057d9d-c615-1a2b-63a2-ab717c29d659@oracle.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-01-30 at 13:23 -0500, Boris Ostrovsky wrote:

> We do netif_carrier_off() first thing in xennet_disconnect_backend() and
> the only place where the timer is rearmed is xennet_alloc_rx_buffers(),
> which is guarded by netif_carrier_ok() check.

Oh well, testing netif_carrier_ok() in packet processing fast path looks
unusual and a waste of cpu cycles. I've never seen that pattern before.

If one day, we remove this netif_carrier_ok() test during a cleanup,
then the race window will open again.
