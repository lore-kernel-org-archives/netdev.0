From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] net: sched: fix NULL pointer dereference when action
 calls some targets
Date: Thu, 17 Aug 2017 23:24:00 +1200
Message-ID: <CADvbK_e+EntdONqnVEEDK+gqzcJHoy2gu5syoYznjaM22zKMCQ@mail.gmail.com>
References: <0fa9a53725dd661571461cf283ec88cf15f4b139.1501932907.git.lucien.xin@gmail.com>
 <CAM_iQpWcg0a46gJ6Qp3F1pqvvsaJYajmDC2uG_mi9Av_vkFo2w@mail.gmail.com>
 <CADvbK_fuuBrh+eOuhQU+SYs9uazH2TRP+KUmhxU=hNZ=EkOT=Q@mail.gmail.com>
 <CAM_iQpXbtHDxVjZ=DoTiLXHLQy6q=JVBa66EqSOy95ZbFg-wkQ@mail.gmail.com>
 <CADvbK_cCQY0McHiZFKSTjdGdAjhB6RBej5n=SH2=hsLYC=Xa7w@mail.gmail.com>
 <20170817100220.GC6928@salvia> <20170817103344.GA7568@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        network dev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34082 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750913AbdHQLYH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 07:24:07 -0400
In-Reply-To: <20170817103344.GA7568@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 17, 2017 at 10:33 PM, Pablo Neira Ayuso <pablo@netfilter.org> wrote:
> On Thu, Aug 17, 2017 at 12:02:20PM +0200, Pablo Neira Ayuso wrote:
>> On Wed, Aug 16, 2017 at 08:39:44PM +1200, Xin Long wrote:
>> > On Wed, Aug 9, 2017 at 7:33 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> > > On Mon, Aug 7, 2017 at 7:33 PM, Xin Long <lucien.xin@gmail.com> wrote:
>> > >> On Tue, Aug 8, 2017 at 9:15 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> > >>> This looks like a completely API burden?
>> > >> netfilter xt targets are not really compatible with netsched action.
>> > >> I've got to say, the patch is just a way to make checkentry return
>> > >> false and avoid panic. like [1] said
>> > >
>> > > I don't doubt you fix a crash, I am thinking if we can
>> > > "fix" the API instead of fixing the caller.
>> > Hi, Cong,
>> >
>> > For now, I don't think it's possible to change APIs or  some of their targets
>> > for the panic caused by action xt calling.
>> >
>> > The common way should be fixed in net_sched side.
>> >
>> > Given that the issue is very easy to triggered,
>> > let's wait for netfilter's replies for another few days,
>> > otherwise I will repost the fix, agree ?
>>
>> Please, post the workaround so the kernel doesn't crash anymore.
>>
>> This is going to be very hard to fix, it's broken since the very
>> beginning...
>
> Wait a second, you could rename par->nft_compat to par->no_entry. From
> net/sched/ you can set this to 1, so the entry checks are ignored.
>
> I'm refering to patch 55917a21d0cc0

par->nft_compat wasn't used to ignore the entry checks, if we rename it
as no_entry, some other targets still needs to update. like the ones in
this patch's changelog:
ECN: ecn_tg_check()
TPROXY: tproxy_tg4_check()

which means these two checks will be ignored for nft as well, that is
not what we want.
As nft has e4.ip.proto and e4.ip.invflags being set which net/sched
gets nothing. they are still different.
