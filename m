From: Oussama Ghorbel <ou.ghorbel@gmail.com>
Subject: Re: [PATCH] Fix the upper MTU limit in ipv6 GRE tunnel
Date: Sun, 6 Oct 2013 16:36:56 +0100
Message-ID: <CABfLueGefWM6m6h44yAMBo7=BMUcA=OvcFVYka06QvsxXUAJtw@mail.gmail.com>
References: <1380880333-3546-1-git-send-email-ou.ghorbel@gmail.com>
	<20131005140636.GA25076@order.stressinduktion.org>
	<CABfLueFYZkzpEpDJ7YcHJaXfm-=QcgnL3-Es8gybea2cAacQQw@mail.gmail.com>
	<20131006151351.GB9295@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Oussama Ghorbel <ou.ghorbel@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131006151351.GB9295@order.stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 6, 2013 at 4:13 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Sun, Oct 06, 2013 at 03:42:15PM +0100, Oussama Ghorbel wrote:
>> The initialization  in ip6gre_tnl_link_config is done as the following:
>> static void ip6gre_tnl_link_config(struct ip6_tnl *t, int set_mtu)
>> {
>> ...
>> int addend = sizeof(struct ipv6hdr) + 4;
>> ...
>> /* Precalculate GRE options length */
>> if (t->parms.o_flags&(GRE_CSUM|GRE_KEY|GRE_SEQ)) {
>> if (t->parms.o_flags&GRE_CSUM)
>> addend += 4;
>> if (t->parms.o_flags&GRE_KEY)
>> addend += 4;
>> if (t->parms.o_flags&GRE_SEQ)
>> addend += 4;
>> }
>> ...
>> dev->hard_header_len = rt->dst.dev->hard_header_len + addend;
>> ...
>> t->hlen = addend;
>> ..
>> }
>>
>> Unless they are other reasons, the hard_header_len is taken into
>> account the GRE_KEY, GRE_SEQ ..
>
> But only if a new route is found. The hard_header_len reinitialization is
> guarded by a (rt == NULL). We may have not found one on boot up.
>
In that case the function will make a return and hlen will be zero.
Subtracting hlen in  ip6gre_tunnel_change_mtu has no effect ...

>> > To make this correct we would have to refactor the usage of the variables a
>> > bit as is done in ipv4/ip_tunnel.c. The safest thing would be to leave this
>> > check as-is currently although we exclude some allowed mtus.
>> >
>> > Perhaps you want to take a look how to achieve that? ;)
>> >
>> Why not, consistency is good ...
>
> Thanks,
>
>   Hannes
>

Thanks,
Oussama
