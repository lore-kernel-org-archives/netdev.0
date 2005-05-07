From: jamal <hadi@cyberus.ca>
Subject: Re: [7/7] [IPSEC] Add XFRMA_SA/XFRMA_POLICY for delete notification
Date: Sat, 07 May 2005 08:04:16 -0400
Message-ID: <1115467457.19561.5.camel@localhost.localdomain>
References: <1112702604.1089.119.camel@jzny.localdomain>
	 <20050409105452.GA7171@gondor.apana.org.au>
	 <20050507071434.GA5716@gondor.apana.org.au>
	 <20050507071824.GA5753@gondor.apana.org.au>
	 <20050507071930.GC5753@gondor.apana.org.au>
	 <20050507072058.GD5753@gondor.apana.org.au>
	 <20050507072139.GE5753@gondor.apana.org.au>
	 <20050507072216.GF5753@gondor.apana.org.au>
	 <20050507072251.GG5753@gondor.apana.org.au>
	 <20050507072349.GH5753@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050507072349.GH5753@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-07-05 at 17:23 +1000, Herbert Xu wrote:
> Hi:
> 
> This patch changes the format of the XFRM_MSG_DELSA and
> XFRM_MSG_DELPOLICY notification so that the main message
> sent is of the same format as that received by the kernel
> if the original message was via netlink.  This also means
> that we won't lose the byid information carried in km_event.
> 

This is incosistent in two ways:
1) Typical netlink behavior is to return the object being deleted.
Every other netlink user behaves that way - the only exception is sone
filters in tc and this is because they cant retrieve that detail
(something that needs resolution at some point). There is nothing that
xfrm_usersa_id provides that can be found in xfrm_usersa_info.
Same for the policy.

2) You cant have one behavior when something is deleted by pfkey and a
different one when it is deleted by netlink.

So i would recommend pulling this one out.

cheers,
jamal
