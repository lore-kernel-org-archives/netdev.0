From: Andrew Morton <akpm@osdl.org>
Subject: Re: Fw: [Bugme-new] [Bug 4628] New: Test server hang while running
 rhr (network) test on RHEL4 with kernel 2.6.12-rc1-mm4
Date: Thu, 26 May 2005 00:38:28 -0700
Message-ID: <20050526003828.213ad052.akpm@osdl.org>
References: <5fc59ff3050516104367a8d5cd@mail.gmail.com>
	<OFB1F7DBFD.6A6514AD-ON48257004.0038A154-48257004.0038E08A@cn.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ganesh.venkatesan@gmail.com, anton@samba.org, herbert@gondor.apana.org.au,
        jgarzik@pobox.com, linuxppc64-dev@lists.linuxppc.org.sgi.com,
        netdev@oss.sgi.com, rende@cn.ibm.com, wangjs@cn.ibm.com,
        cdlwangl@cn.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jian Jun He <hejianj@cn.ibm.com>, john.ronciak@intel.com,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
In-Reply-To: <OFB1F7DBFD.6A6514AD-ON48257004.0038A154-48257004.0038E08A@cn.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jian Jun He <hejianj@cn.ibm.com> wrote:
>
> I download e100-3.4.8 and installed in the test machine (both client and
>  server). But the server still hang while running rhr (network) test. :(

e100 is one of those drivers which we'd rather like to have working properly.

Can we please confirm that a) this bug is not fixed in 2.6.12-rc5 and b)
nobody has seen a patch which fixes it?



For reference:

Herbert Xu <herbert@gondor.apana.org.au> wrote:
>
> Andrew Morton <akpm@osdl.org> wrote:
> > 
> > Might be a bug in the e100 driver, might not be.
> > 
> > I assume this is the
> > 
> >        BUG_ON(skb->list != NULL);
> 
> It certainly is a bug in e100.
> 
> e100_tx_timeout -> e100_down -> e100_rx_clean_list
> 
> is racing against
> 
> e100_poll -> e100_rx_clean -> e100_rx_indicate
> 
> e100_rx_clean/e100_rx_indicate takes an skb off the RX ring and
> while it's being processed e100_rx_clean_list comes along and
> frees it.
> 
> >From a quick check similar problems may exist in other drivers that
> have lockless ->poll() functions with RX rings.
