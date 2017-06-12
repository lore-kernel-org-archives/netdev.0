From: Ivan Delalande <colona@arista.com>
Subject: Re: [PATCH v2 2/2] tcp: md5: extend the tcp_md5sig struct to specify
 a key address prefix
Date: Tue, 13 Jun 2017 00:49:12 +0200
Message-ID: <20170612224912.GE17030@ycc.fr>
References: <20170607005414.25361-1-colona@arista.com>
 <20170610021449.16091-1-colona@arista.com>
 <20170610021449.16091-2-colona@arista.com>
 <20170610.185811.1771245027556677313.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170610.185811.1771245027556677313.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 10, 2017 at 06:58:11PM -0400, David Miller wrote:
> From: Ivan Delalande <colona@arista.com>
> Date: Fri,  9 Jun 2017 19:14:49 -0700
> 
> > Add a flag field and address prefix length at the end of the tcp_md5sig
> > structure so users can configure an address prefix length along with a
> > key. Make sure shorter option values are still accepted in
> > tcp_v4_parse_md5_keys and tcp_v6_parse_md5_keys to maintain backward
> > compatibility.
> > 
> > Signed-off-by: Bob Gilligan <gilligan@arista.com>
> > Signed-off-by: Eric Mowat <mowat@arista.com>
> > Signed-off-by: Ivan Delalande <colona@arista.com>
> 
> As I believe was previously stated, the problem with this approach is
> that if a new tool requests the prefix length and is run on an older
> kernel, the kernel will return success even though the prefix length
> was not taken into account.
> 
> We do not want to get a success back when the operation requested was
> not performed.

Ah yeah that's right, sorry, definitely not great.

So I guess our only other option is to add a new socket option, like
TCP_MD5SIG_EXT which would use the extended version of struct tcp_md5sig
from this patch. Is it justified for this feature, or do you see any
other way to achieve this?

Thanks,
-- 
Ivan Delalande
Arista Networks
