From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH] tcp: fix retransmission in repair mode
Date: Thu, 15 Nov 2012 18:10:59 +0400
Message-ID: <50A4F7F3.5080500@parallels.com>
References: <1352988197-14414-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, criu@openvz.org,
	linux-kernel@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Andrey Vagin <avagin@openvz.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352988197-14414-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/15/2012 06:03 PM, Andrey Vagin wrote:
> From: Andrew Vagin <avagin@openvz.org>
> 
> Currently if a socket was repaired with a few packet in a write queue,
> a kernel bug may be triggered:
> 
> kernel BUG at net/ipv4/tcp_output.c:2330!
> RIP: 0010:[<ffffffff8155784f>] tcp_retransmit_skb+0x5ff/0x610
> 
> According to the initial realization v3.4-rc2-963-gc0e88ff,
> all skb-s should look like already posted. This patch fixes code
> according with this sentence.
> 
> Here are three points, which were not done in the initial patch:
> 1. A tcp send head should not be changed
> 2. Initialize TSO state of a skb
> 3. Reset the retransmission time
> 
> This patch moves logic from tcp_sendmsg to tcp_write_xmit. A packet
> passes the ussual way, but isn't sent to network. This patch solves
> all described problems and handles tcp_sendpages.
> 
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Andrey Vagin <avagin@openvz.org>

Acked-by: Pavel Emelyanov <xemul@parallels.com>
