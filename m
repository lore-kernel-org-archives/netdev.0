From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3] iproute2 and xfrm
Date: Sat, 17 Jul 2004 09:05:53 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040716230552.GA14245@gondor.apana.org.au>
References: <20040703094632.GA14235@gondor.apana.org.au> <20040705160500.208591b5@localhost> <20040706140550.2d483dc8@dell_ss3.pdx.osdl.net> <20040707130950.0112edf6@localhost> <20040707140533.41c66c03@localhost> <20040707155602.4698121a@localhost> <20040707110315.GA26100@gondor.apana.org.au> <20040709125100.3edce4e9@localhost> <20040714174233.2fc7dbc2@localhost> <20040715150219.24a498a6@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20040715150219.24a498a6@localhost>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jul 15, 2004 at 03:02:19PM +0900, Masahide NAKAMURA wrote:
> 
> This patch is for iproute2.
> Please check comment in a ChangeSet below.

Thanks for the patches.  It's much better.

I think some simplifications can still be made:

Policies:

* sel/upsec are redundant.  You can disambiguate src/dst/proto
  by whether they're preceded by tmpl or not.
* proto/sport/dport should be omitted if they're zero.
* level should be omitted if it's required.
* spi should be omitted if it's zero.
* index should be omitted in the default output.  It's not a part of
  the policy specification.
* action should be omitted if it's allow.

States:

* spi should be shown in hex by default.  Related tools like tcpdump show
  hex so this makes debugging easier.
* flag should be omitted if it's zero.
* Please use auth/enc instead of A/E.  The latter looks out-of-place in ip(8).
* You can also skip algo and use auth/enc to detect the start of an
  algorithm.
* replay_window is not a statistic so it should shown in the main output.
* The selector should be shown in the main output if it is not zero.

The above changes can be summarised by these two principles:

1. By cut-n-pasting the output of ip x p/s, I should be able to recreate
   the exact same policies/states.
2. The output of ip x p/s should be minimal so that it is easy to
   understand and type in.

Please also fix ip -o x so that the output can be on one line.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
