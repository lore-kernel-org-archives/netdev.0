From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: socket: fix recvmmsg not returning error from
 sock_error
Date: Tue, 21 Feb 2017 13:35:58 -0500 (EST)
Message-ID: <20170221.133558.1628815110115665532.davem@davemloft.net>
References: <20170221173551.3471-1-maxime.jayat@mobile-devices.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: maxime.jayat@mobile-devices.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170221173551.3471-1-maxime.jayat@mobile-devices.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maxime Jayat <maxime.jayat@mobile-devices.fr>
Date: Tue, 21 Feb 2017 18:35:51 +0100

> Commit 34b88a68f26a ("net: Fix use after free in the recvmmsg exit path"),
> changed the exit path of recvmmsg to always return the datagrams
> variable and modified the error paths to set the variable to the error
> code returned by recvmsg if necessary.
> 
> However in the case sock_error returned an error, the error code was
> then ignored, and recvmmsg returned 0.
> 
> Change the error path of recvmmsg to correctly return the error code
> of sock_error.
> 
> The bug was triggered by using recvmmsg on a CAN interface which was
> not up. Linux 4.6 and later return 0 in this case while earlier
> releases returned -ENETDOWN.
> 
> Fixes: 34b88a68f26a ("net: Fix use after free in the recvmmsg exit path")
> Signed-off-by: Maxime Jayat <maxime.jayat@mobile-devices.fr>

Good catch, applied and queued up for -stable.
