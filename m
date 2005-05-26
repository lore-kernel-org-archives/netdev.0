From: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
Subject: Re: Fw: [Bugme-new] [Bug 4628] New: Test server hang while running rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4
Date: Thu, 26 May 2005 16:08:17 -0700
Message-ID: <5fc59ff30505261608541b74fb@mail.gmail.com>
References: <468F3FDA28AA87429AD807992E22D07E056F6B37@orsmsx408>
	 <20050526213421.GA8077@gondor.apana.org.au>
Reply-To: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        Andrew Morton <akpm@osdl.org>, Jian Jun He <hejianj@cn.ibm.com>,
        anton@samba.org, rende@cn.ibm.com,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, jgarzik@pobox.com,
        wangjs@cn.ibm.com, "Ronciak, John" <john.ronciak@intel.com>,
        cdlwangl@cn.ibm.com, linuxppc64-dev@lists.linuxppc.org.sgi.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050526213421.GA8077@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert:

I do not get it. Bear with my ignorance.

e100_tx_timeout does not call e100_down. 

It is called from e100_tx_timeout_task which is invoked as a result of
schedule_work. Are you saying that it would still not have the right
context to call netif_disable_poll()?

thanks,
ganesh.

On 5/26/05, Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Thu, May 26, 2005 at 01:41:53PM -0700, Venkatesan, Ganesh wrote:
> >
> > I already responded to this analysis before. In any case, here it is:
> >
> > Later versions of e100 (3.4.8 for instance) includes a call to
> > netif_poll_disable in e100_down. This is supposed to wait and when it
> 
> As I said last time, this is broken since the code path in question
> starts from tx_timeout which is called in softirq context.  You'll
> need to schedule a work struct at least.
> 
> Cheers,
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
>
