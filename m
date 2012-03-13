From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] tun: don't hold network namespace by tun sockets
Date: Mon, 12 Mar 2012 17:14:11 -0700 (PDT)
Message-ID: <20120312.171411.899890153797891857.davem@davemloft.net>
References: <20120312125833.24166.72610.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, ebiederm@aristanetworks.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	shemminger@vyatta.com, devel@openvz.org
To: skinsbursky@parallels.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120312125833.24166.72610.stgit@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

aFrom: Stanislav Kinsbursky <skinsbursky@parallels.com>
Date: Mon, 12 Mar 2012 16:59:41 +0400

> v3: added previously removed sock_put() to the tun_release() callback, because
> sk_release_kernel() doesn't drop the socket reference.
> 
> v2: sk_release_kernel() used for socket release. Dummy tun_release() is
> required for sk_release_kernel() ---> sock_release() ---> sock->ops->release()
> call.
> 
> TUN was designed to destroy it's socket on network namesapce shutdown. But this
> will never happen for persistent device, because it's socket holds network
> namespace.
> This patch removes of holding network namespace by TUN socket and replaces it
> by creating socket in init_net and then changing it's net it to desired one. On
> shutdown socket is moved back to init_net prior to final put.
> 
> Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

Looks good, applied, thanks.
