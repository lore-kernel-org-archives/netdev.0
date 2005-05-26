From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 4628] New: Test server hang while running rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4
Date: Fri, 27 May 2005 07:34:21 +1000
Message-ID: <20050526213421.GA8077@gondor.apana.org.au>
References: <468F3FDA28AA87429AD807992E22D07E056F6B37@orsmsx408>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, Jian Jun He <hejianj@cn.ibm.com>,
        anton@samba.org, rende@cn.ibm.com, ganesh.venkatesan@gmail.com,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, jgarzik@pobox.com,
        wangjs@cn.ibm.com, "Ronciak, John" <john.ronciak@intel.com>,
        cdlwangl@cn.ibm.com, linuxppc64-dev@lists.linuxppc.org.sgi.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Content-Disposition: inline
In-Reply-To: <468F3FDA28AA87429AD807992E22D07E056F6B37@orsmsx408>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 26, 2005 at 01:41:53PM -0700, Venkatesan, Ganesh wrote:
> 
> I already responded to this analysis before. In any case, here it is:
> 
> Later versions of e100 (3.4.8 for instance) includes a call to
> netif_poll_disable in e100_down. This is supposed to wait and when it

As I said last time, this is broken since the code path in question
starts from tx_timeout which is called in softirq context.  You'll
need to schedule a work struct at least.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
