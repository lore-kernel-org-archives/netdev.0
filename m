From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] hv_sock: add locking in the open/close/release
 code paths
Date: Sat, 21 Oct 2017 02:21:29 +0100 (WEST)
Message-ID: <20171021.022129.807124847963198670.davem@davemloft.net>
References: <KL1P15301MB0006B746A23A2FCE695D08DEBF420@KL1P15301MB0006.APCP153.PROD.OUTLOOK.COM>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sthemmin@microsoft.com, kys@microsoft.com,
        devel@linuxdriverproject.org, linux-kernel@vger.kernel.org,
        vkuznets@redhat.com, haiyangz@microsoft.com, cavery@redhat.com,
        rolf.neugebauer@docker.com, marcelo.cerri@canonical.com,
        Jork.Loeser@microsoft.com
To: decui@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <KL1P15301MB0006B746A23A2FCE695D08DEBF420@KL1P15301MB0006.APCP153.PROD.OUTLOOK.COM>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dexuan Cui <decui@microsoft.com>
Date: Thu, 19 Oct 2017 03:33:14 +0000

> 
> Without the patch, when hvs_open_connection() hasn't completely established
> a connection (e.g. it has changed sk->sk_state to SS_CONNECTED, but hasn't
> inserted the sock into the connected queue), vsock_stream_connect() may see
> the sk_state change and return the connection to the userspace, and next
> when the userspace closes the connection quickly, hvs_release() may not see
> the connection in the connected queue; finally hvs_open_connection()
> inserts the connection into the queue, but we won't be able to purge the
> connection for ever.
> 
> Signed-off-by: Dexuan Cui <decui@microsoft.com>

Applied.
