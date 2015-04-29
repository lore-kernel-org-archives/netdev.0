From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH V2 net 1/1] hv_netvsc: Fix a bug in netvsc_start_xmit()
Date: Wed, 29 Apr 2015 03:51:44 +0000
Message-ID: <066b094eb64e418e835c066214d8ef73@SIXPR30MB031.064d.mgd.msft.net>
References: <1430269188-31701-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: KY Srinivasan <kys@microsoft.com>, "davem@davemloft.net"
 <davem@davemloft.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 "olaf@aepfle.de" <olaf@aepfle.de>, "apw@canonical.com" <apw@canonical.com>,
 "jasowang@redhat.com" <jasowang@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1430269188-31701-1-git-send-email-kys@microsoft.com>
Content-Language: en-US
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: devel [mailto:driverdev-devel-bounces@linuxdriverproject.org] On
> Behalf Of K. Y. Srinivasan
> Sent: Wednesday, April 29, 2015 9:00
> To: davem@davemloft.net; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com
> Subject: [PATCH V2 net 1/1] hv_netvsc: Fix a bug in netvsc_start_xmit()
> 
> Commit b08cc79155fc26d0d112b1470d1ece5034651a4b eliminated
> memory
> allocation in the packet send path:
> 
>     "hv_netvsc: Eliminate memory allocation in the packet send path
> 
>     The network protocol used to communicate with the host is the remote
> ndis (rndis)
>     protocol. We need to decorate each outgoing packet with a rndis header
> and
>     additional rndis state (rndis per-packet state). To manage this state, we
>     currently allocate memory in the transmit path. Eliminate this allocation
> by
>     requesting additional head room in the skb."
> 
> This commit introduced a bug since it did not account for the case if the skb
> was cloned. Fix this bug.
> 
> 
> Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
> ---
> 	V2: Used skb_cow_head() based on Dave Miller's feedback
> 	V2: Fixed up the commit log based on feedback from Sergei
> Shtylyov
> 
>  drivers/net/hyperv/hyperv_net.h |    1 -
>  drivers/net/hyperv/netvsc.c     |    5 -----
>  drivers/net/hyperv/netvsc_drv.c |   27 +++++++--------------------
>  3 files changed, 7 insertions(+), 26 deletions(-)

Without the patch, the guest can panic due to memory corruption.

I confirm the patch can fix the panic I saw.

Tested-by: Dexuan Cui <decui@microsoft.com>

-- Dexuan
