From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] xfrm: Fix unaligned access in
 xfrm_notify_sa() for DELSA
Date: Wed, 21 Oct 2015 06:17:37 -0700 (PDT)
Message-ID: <20151021.061737.817854527348057019.davem@davemloft.net>
References: <65f37efeff5af105c89493dda4f38c61e4cd495f.1445286755.git.sowmini.varadhan@oracle.com>
	<20151021065704.GM7701@secunet.com>
	<20151021105442.GM6948@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, linux-crypto@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, dhowells@redhat.com,
	zohar@linux.vnet.ibm.com, David.Woodhouse@intel.com
To: sowmini.varadhan@oracle.com
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <20151021105442.GM6948@oracle.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Wed, 21 Oct 2015 06:54:42 -0400

> On (10/21/15 08:57), Steffen Klassert wrote:
>> > --- a/net/xfrm/xfrm_user.c
>> > +++ b/net/xfrm/xfrm_user.c
>> > @@ -2659,7 +2659,7 @@ static int xfrm_notify_sa(struct xfrm_state *x, const struct km_event *c)
>> >  		if (attr == NULL)
>> >  			goto out_free_skb;
>> >  
>> > -		p = nla_data(attr);
>> > +		p = PTR_ALIGN(nla_data(attr), __alignof__(*p));
>> 
>> Hm, this breaks userspace notifications on 64-bit systems.
>> Userspace expects this to be aligned to 4, with your patch
>> it is aligned to 8 on 64-bit.
>> 
>> Without your patch I get the correct notification when deleting a SA:
>> 
> 
> But __alignof__(*p) is 8 on sparc, and without the patch I get
> all types of unaligned access. So what do you suggest as the fix?

The accesses have to be done using something like get_unaligned() and
put_unaligned().

Sorry, but the protocol is set in stone and this is unfortunately how
it is.
