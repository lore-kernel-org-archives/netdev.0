From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH] tcp: restore rcv_wscale in a repair mode (v2)
Date: Thu, 20 Sep 2012 13:31:57 +0400
Message-ID: <505AE28D.9060901@parallels.com>
References: <1348083600-3881500-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andrew Vagin <avagin@openvz.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1348083600-3881500-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/19/2012 11:40 PM, Andrew Vagin wrote:
> rcv_wscale is a symetric parameter with snd_wscale.
> 
> Both this parameters are set on a connection handshake.
> 
> Without this value a remote window size can not be interpreted correctly,
> because a value from a packet should be shifted on rcv_wscale.
> 
> And one more thing is that wscale_ok should be set too.
> 
> This patch doesn't break a backward compatibility.
> If someone uses it in a old scheme, a rcv window
> will be restored with the same bug (rcv_wscale = 0).
> 
> v2: Save backward compatibility on big-endian system. Before
>     the first two bytes were snd_wscale and the second two bytes were
>     rcv_wscale. Now snd_wscale is opt_val & 0xFFFF and rcv_wscale >> 16.
>     This approach is independent on byte ordering.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> CC: Pavel Emelyanov <xemul@parallels.com>
> Signed-off-by: Andrew Vagin <avagin@openvz.org>

Acked-by: Pavel Emelyanov <xemul@parallels.com>
