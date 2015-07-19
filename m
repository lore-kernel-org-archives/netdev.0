From: Mathias Krause <minipli@googlemail.com>
Subject: Re: [PATCH net-next] net: #ifdefify sk_classid member of struct sock
Date: Sun, 19 Jul 2015 21:57:18 +0200
Message-ID: <CA+rthh-nL5SemBqxEJah493E8iofaWb1zg=JJmiKifamUL9RJg@mail.gmail.com>
References: <1437329861-11758-1-git-send-email-minipli@googlemail.com>
	<20150719.114228.179586744105997642.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150719.114228.179586744105997642.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 19 July 2015 at 20:42, David Miller <davem@davemloft.net> wrote:
> From: Mathias Krause <minipli@googlemail.com>
> Date: Sun, 19 Jul 2015 20:17:41 +0200
>
>> The sk_classid member is only required when CONFIG_CGROUP_NET_CLASSID is
>> enabled. #ifdefify it to reduce the size of struct sock on 32 bit
>> systems, at least.
>>
>> Signed-off-by: Mathias Krause <minipli@googlemail.com>
>
> Are you sure NFT_META_CGROUP cannot enter nft_meta_get_eval()?  If so it'll
> WARN_ON().

I just tried to bring the code in line as it already is for
NFT_META_RTCLASSID and NFT_META_SECMARK. But, obviously, I messed it
up by missing the nft_meta_get_init() function. Sorry for that!

The init function gets called prior to the eval function (see
nft_expr_init() and nf_tables_newrule()). If it returns an error, the
latter won't be called. So the fix is, to add the #ifdef to
nft_meta_get_init() as well.

Another direct caller of  nft_meta_get_eval() is
nft_meta_bridge_get_eval(). However, it also complies to the init /
eval rule by calling nft_meta_get_init() in its init function, so will
error out in the case, too.

I'll send a v2 soon.

Thanks for the review!

> I really don't like changes like this.

Sorry. I should have taken more attention.


Thanks,
Mathias
