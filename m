From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] multipath routing algorithm, better patch
Date: Fri, 01 Jul 2005 02:43:06 +0200
Message-ID: <42C4919A.5000009__3332.50160697407$1120178355$gmane$org@trash.net>
References: <Pine.GSO.4.61.0506302014160.7400@rac1.wam.umd.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick Jenkins <patjenk@wam.umd.edu>
In-Reply-To: <Pine.GSO.4.61.0506302014160.7400@rac1.wam.umd.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick Jenkins wrote:
> Hi,
> 
> The last patch wont work, this should.
> 
> This patch assigns the multipath routing algorithm into the fib_info
> struct's fib_mp_alg variable. Previously, the algorithm was always set to
> IP_MP_ALG_NONE which was incorrect. This patch corrects the problem by
> assigning the correct value when a fib_info is initialized.
> 
> This patch was tested against kernel 2.6.12.1 for all multipath routing
> algorithms (none, round robin, interface round robin, random, weighted
> random).

Multiple algorithms can be compiled in at once, so this patch is wrong.
mp_alg is supplied by userspace:

        if (rta->rta_mp_alg) {
                mp_alg = *rta->rta_mp_alg;

                if (mp_alg < IP_MP_ALG_NONE ||
                    mp_alg > IP_MP_ALG_MAX)
                        goto err_inval;
        }

If it isn't set correctly its an iproute problem. Did you actually
experience any problems?

Regards
Patrick
