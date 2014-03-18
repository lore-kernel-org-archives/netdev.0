From: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 6/6] net: Free skbs from irqs when possible.
Date: Tue, 18 Mar 2014 16:41:55 +0100
Message-ID: <2c96faab-4293-4e7f-b8e0-4997af745fbf@email.android.com>
References: <20140314.225923.61318448733570839.davem@davemloft.net> <87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com> <20140317.154916.2276987764507311378.davem@davemloft.net> <87iorcgh5d.fsf_-_@xmission.com> <87fvmgf2c7.fsf_-_@xmission.com> <1395149407.22343.8.camel@deadeye.wl.decadent.org.uk> <87lhw7inzg.fsf@nemi.mork.no> <1395156229.9114.35.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <ben@decadent.org.uk>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:52241 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750798AbaCRPmd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 11:42:33 -0400
In-Reply-To: <1395156229.9114.35.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 18 March 2014 16:23:49 CET, Eric Dumazet <eric.dumazet@gmail.com> wr=
ote:
>On Tue, 2014-03-18 at 15:24 +0100, Bj=C3=B8rn Mork wrote:
>> Ben Hutchings <ben@decadent.org.uk> writes:
>> > On Mon, 2014-03-17 at 23:27 -0700, Eric W. Biederman wrote:
>> > [...]
>> >> --- a/net/core/skbuff.c
>> >> +++ b/net/core/skbuff.c
>> >> @@ -554,14 +554,21 @@ static void kfree_skbmem(struct sk_buff
>*skb)
>> >> =20
>> >>  static void skb_release_head_state(struct sk_buff *skb)
>> >>  {
>> >> +	WARN_ONCE(in_irq() && !skb_irq_freeable(skb),
>> >> +		  "%s called from irq! sp %d nfct %d frag_list %d %pF dst %lx"=
,
>> >> +		  __func__,
>> >> +		  IS_ENABLED(CONFIG_XFRM) ? !!skb->sp : 0,
>> >> +		  IS_ENABLED(CONFIG_NF_CONNTRACK) ? !!skb->nfct : 0,
>> > [...]
>> >
>> > This is a syntax error if CONFIG_XFRM or CONFIG_NF_CONNTRACK is
>> > disabled; you have to use #ifdef's.
>>=20
>> Are you sure?  I thought one of the ideas behind these macros was
>that
>> they would always evaluate to 0 or 1.  The docs says:
>>=20
>>  * IS_ENABLED(CONFIG_FOO) evaluates to 1 if CONFIG_FOO is set to 'y'
>or 'm',
>>  * 0 otherwise.
>>=20
>>=20
>> See include/linux/kconfig.h for the macro magic making this
>> happen. Looks like fun figuring that out.
>
>It has nothing to do with this.
>
>Try following code, and you'll get a compilation error.
>
>unsigned int can_this_fly(struct sk_buff *skb)
>{
>	return IS_ENABLED(CONFIG_NOWAY_SIR) ? skb->unknown_field : 0;
>}

Doh. Of course. Thanks for spoon feeding me that.



Bj=C3=B8rn
