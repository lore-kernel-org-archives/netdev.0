From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: netif_rx packet dumping
Date: Tue, 8 Mar 2005 15:51:58 -0300
Message-ID: <39e6f6c705030810515795ccb6@mail.gmail.com>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>
	 <42278122.6000000@ev-en.org>
	 <20050303133659.0d224e61.davem@davemloft.net>
	 <42278554.2090902@ev-en.org>
	 <20050303135718.2e1a0170.davem@davemloft.net>
	 <422DC7CE.2040800@ev-en.org> <m1y8cykr7i.fsf@muc.de>
	 <20050308100902.24b67b2f.davem@davemloft.net>
	 <20050308181844.GA37392@muc.de>
	 <20050308183759.GE31837@postel.suug.ch>
Reply-To: acme@conectiva.com.br
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@muc.de>, "David S. Miller" <davem@davemloft.net>,
        baruch@ev-en.org, shemminger@osdl.org, netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050308183759.GE31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 8 Mar 2005 19:37:59 +0100, Thomas Graf <tgraf@suug.ch> wrote:

> Speaking of it, I see tcp_sock is marginal over 2**10 on 32 bit archs and
> Stephen's plans to outsource the cc bits brings us closer to the border.
> Would it be worth to try and get it below 2**10? I spotted some places
> for optimizations but not enough to really save the needed amount.

sk_protinfo, sk_slab, sk_zapped are going away when I finish my 
connection_sock-2.6 series.

sk_protinfo isn't needed if all proto families use the sk_alloc + kmalloc, i.e.
specifying the size of the proto specific socket (like tcp_sock) in
"zero_it"  and
passing NULL in the slab parameter, like I did with bluetooth today and will do
with the ham radio, the last ones using sk_protinfo.

sk_slab will be get from only in sk->sk_prot->slab.

sk_zapped was just a debugging member that got reused, and can be turned
into a SOCK_ZAPPED in sk_flags.


-- 
- Arnaldo
