From: jamal <hadi@cyberus.ca>
Subject: Re: [7/7] [IPSEC] Add XFRMA_SA/XFRMA_POLICY for delete notification
Date: Sat, 07 May 2005 08:46:44 -0400
Message-ID: <1115470004.19561.49.camel@localhost.localdomain>
References: <20050409105452.GA7171@gondor.apana.org.au>
	 <20050507071434.GA5716@gondor.apana.org.au>
	 <20050507071824.GA5753@gondor.apana.org.au>
	 <20050507071930.GC5753@gondor.apana.org.au>
	 <20050507072058.GD5753@gondor.apana.org.au>
	 <20050507072139.GE5753@gondor.apana.org.au>
	 <20050507072216.GF5753@gondor.apana.org.au>
	 <20050507072251.GG5753@gondor.apana.org.au>
	 <20050507072349.GH5753@gondor.apana.org.au>
	 <1115467457.19561.5.camel@localhost.localdomain>
	 <20050507122504.GA21693@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050507122504.GA21693@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-07-05 at 22:25 +1000, Herbert Xu wrote:
> On Sat, May 07, 2005 at 08:04:16AM -0400, jamal wrote:
> > 
> > This is incosistent in two ways:
> > 1) Typical netlink behavior is to return the object being deleted.
> > Every other netlink user behaves that way - the only exception is sone
> > filters in tc and this is because they cant retrieve that detail
> > (something that needs resolution at some point). There is nothing that
> > xfrm_usersa_id provides that can be found in xfrm_usersa_info.
> > Same for the policy.
> 
> This analogy is flawed since unlike other rtnetlink delete operations
> the xfrm delete operations do not carry the same payload type as their
> add/update cousins.
> 

No, this is not true. Study the tc code.
It is nice to be able to return exactly the same detail - user space can
then infer what exactly happened. It is nicer to be able to return more
detail because user space doesnt have to infer anything.

> > 2) You cant have one behavior when something is deleted by pfkey and a
> > different one when it is deleted by netlink.
> 
> As far as I can see the behaviour is identical.
> 

If this is true, then #1 is forgivable.  This was my main concern.

You describe the patch this way

---
This patch changes the format of the XFRM_MSG_DELSA and
XFRM_MSG_DELPOLICY notification so that the main message
sent is of the same format as that received by the kernel
if the original message was via netlink.
----

That it only happens when you delete via netlink. Is this not so?

cheers,
jamal
