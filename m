From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Fw: [Bug 4279] New: When I try to start vpnc the
 net/core/skbuff.c:91 crash
Date: Thu, 10 Mar 2005 19:20:23 -0800
Message-ID: <20050310192023.1270fef6.davem@davemloft.net>
References: <20050303095832.6a084856@dxpl.pdx.osdl.net>
	<4228A354.8020904@qualcomm.com>
	<4228AD8F.4020000@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: maxk@qualcomm.com, shemminger@osdl.org, netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4228AD8F.4020000@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 04 Mar 2005 19:48:47 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Max Krasnyansky wrote:
> > Hi Stephen,
> > 
> >> Looks like a something wrong with tun driver on 2.6.11
> > 
> > Thanks for forwarding this. I'll take a look at it.
> > As far as I remember nothing really changed in the TUN write logic.
> > Must be some other changes broke it.
> 
> This check is wrong, gcc optimizes it away:
> 
>                 if ((len -= sizeof(pi)) > len)
> 			return -EINVAL;
> 
> This could be responsible for the BUG. If len is 2 or 3 and TUN_NO_PI
> isn't set it underflows. alloc_skb() allocates len + 2, which is 0 or
> 1 byte. skb_reserve tries to reserve 2 bytes and things explode in
> skb_put.

Good catch Patrick.

Patch applied, thanks.
