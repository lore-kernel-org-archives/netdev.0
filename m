From: David Coulson <david@davidcoulson.net>
Subject: Re: skb_checksum_help
Date: Tue, 25 Jan 2005 09:16:37 -0500
Message-ID: <41F654C5.5080108@davidcoulson.net>
References: <20050124005348.GL23931@postel.suug.ch> <E1Cst4o-0007bD-00@gondolin.me.apana.org.au> <20050123202715.281ac87c.davem@davemloft.net> <20050124121610.GP23931@postel.suug.ch> <41F50B6C.6010107@davidcoulson.net> <20050124151510.GV23931@postel.suug.ch> <20050124225423.GA15405@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, "David S. Miller" <davem@davemloft.net>,
        kaber@trash.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050124225423.GA15405@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Herbert Xu wrote:

> OK, I think I've found the problem.  It's a totally innocuous bug
> in ip_fragment/ip6_fragment.  When we're in the fast path and use
> the pre-existing frag_list skb's, we forgot to clear ip_summed.

Okay - I applied Herbert's patch to my kernels and it all looks good 
now. Thomas showed me how to generate fragged packets using hping2 
(handy tool!) and replicate the kernel failure.

I slammed it with hping2 for a while, and didn't experience any kernel 
errors or see any debug information from previous patches. Everything is 
working as it should be, and I verified I saw the fragged packets in 
tcpdump to make sure they were being routed properly.

:-)

David

-- 
David J. Coulson
email: david@davidcoulson.net
web: http://www.davidcoulson.net/
phone: (216) 920-3100 / (216) 258-4942
