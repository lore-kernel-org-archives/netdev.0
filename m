From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/2] [net-next] udp: provide udp{4,6}_lib_lookup for
 nf_socket_ipv{4,6}
Date: Thu, 10 Nov 2016 00:08:23 +0100
Message-ID: <20161109230823.GA12171@salvia>
References: <20161108132914.1495283-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Eric Dumazet <edumazet@google.com>,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161108132914.1495283-1-arnd@arndb.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 08, 2016 at 02:28:18PM +0100, Arnd Bergmann wrote:
> Since commit ca065d0cf80f ("udp: no longer use SLAB_DESTROY_BY_RCU")
> the udp6_lib_lookup and udp4_lib_lookup functions are only
> provided when it is actually possible to call them.
> 
> However, moving the callers now caused a link error:
> 
> net/built-in.o: In function `nf_sk_lookup_slow_v6':
> (.text+0x131a39): undefined reference to `udp6_lib_lookup'
> net/ipv4/netfilter/nf_socket_ipv4.o: In function `nf_sk_lookup_slow_v4':
> nf_socket_ipv4.c:(.text.nf_sk_lookup_slow_v4+0x114): undefined reference to `udp4_lib_lookup'
> 
> This extends the #ifdef so we also provide the functions when
> CONFIG_NF_SOCKET_IPV4 or CONFIG_NF_SOCKET_IPV6, respectively
> are set.

Applied, thanks Arnd!
