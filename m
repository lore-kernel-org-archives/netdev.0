From: Daniele Venzano <webvenza@libero.it>
Subject: Re: [Bugme-new] [Bug 4223] New: sis900 kernel oop at boot
Date: Fri, 18 Feb 2005 19:17:06 +0100
Message-ID: <5ce5a5e4fed105451a3b7700bf40b04d@libero.it>
References: <E1D26BP-0005Lg-00@gondolin.me.apana.org.au>
Mime-Version: 1.0 (Apple Message framework v619.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, akpm@osdl.org (Andrew Morton), mangus@deprecated.it,
        jgarzik@pobox.com
In-Reply-To: <E1D26BP-0005Lg-00@gondolin.me.apana.org.au>
To: Herbert Xu <herbert@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 18/feb/05, at 12:20, Herbert Xu wrote:
> OK, this happened because we got preempted before sis900_mii_probe
> finished setting the sis_priv->mii.  Theoretically this can happen
> with SMP as well but I suppose the number of SMP machines with sis900
> is fairly small.
>
> Anyway, the fix is to make sure that sis900_mii_probe is done before
> the device can be opened.  This patch does it by moving the setup
> after register_netdevice into the netdev init function.
I think the patch is ok, but it will not apply with the latest changes  
I sent to Jeff Garzik (see  
<http://gkernel.bkbits.net:8080/netdev-2.6/related/drivers/net/ 
sis900.c?nav=index.html|src/.|src/drivers|src/drivers/net>.
Don't know if this is a problem, since those changes have not yet  
reached Linus tree.

> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Daniele Venzano <webvenza@libero.it>

--
Daniele Venzano
http://teg.homeunix.org
