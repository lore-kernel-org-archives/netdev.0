From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next] bnxt_en: Fix randconfig build errors.
Date: Fri, 27 Oct 2017 23:41:28 -0700
Message-ID: <CACKFLimFNuznOMSvYrnujauSs8JRhC6_Qtc33PyiRPFo4cgeAQ@mail.gmail.com>
References: <1509170170-14847-1-git-send-email-michael.chan@broadcom.com>
 <427d0d07-2bb6-da88-d562-05f1a7f5f6f3@huawei.com> <20171027231515.1816951e@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Yunsheng Lin <linyunsheng@huawei.com>,
        David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:47593 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751156AbdJ1Gl3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 02:41:29 -0400
Received: by mail-oi0-f65.google.com with SMTP id h200so14022997oib.4
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 23:41:29 -0700 (PDT)
In-Reply-To: <20171027231515.1816951e@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 27, 2017 at 11:15 PM, Jakub Kicinski <kubakici@wp.pl> wrote:
> On Sat, 28 Oct 2017 14:05:04 +0800, Yunsheng Lin wrote:
>> Hi, Michael
>>
>> On 2017/10/28 13:56, Michael Chan wrote:
>> > Fix undefined symbols when CONFIG_VLAN_8021Q or CONFIG_INET is not set.
>> >
>> > Fixes: 8c95f773b4a3 ("bnxt_en: add support for Flower based vxlan encap/decap offload")
>> > Reported-by: Jakub Kicinski <kubakici@wp.pl>
>> > Signed-off-by: Michael Chan <michael.chan@broadcom.com>
>> > ---
>> >  drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c | 6 ++++++
>> >  1 file changed, 6 insertions(+)
>> >
>> > diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
>> > index 798d139..d5031f4 100644
>> > --- a/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
>> > +++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
>> > @@ -904,6 +904,7 @@ static int bnxt_tc_resolve_tunnel_hdrs(struct bnxt *bp,
>> >                                    struct bnxt_tc_l2_key *l2_info,
>> >                                    struct net_device *real_dst_dev)
>> >  {
>> > +#ifdef CONFIG_INET
>>
>> Can we use #if IS_ENABLED(CONFIG_INET) here too?
>>
>> I am not familiar with IS_ENABLED, just thought it would be
>> good to be constistent because you are using IS_ENABLED below.
>
> It's OK, CONFIG_INET can't be a module.
>
>> >     struct flowi4 flow = { {0} };
>> >     struct net_device *dst_dev;
>> >     struct neighbour *nbr;
>> > @@ -925,6 +926,7 @@ static int bnxt_tc_resolve_tunnel_hdrs(struct bnxt *bp,
>> >      */
>> >     dst_dev = rt->dst.dev;
>> >     if (is_vlan_dev(dst_dev)) {
>> > +#if IS_ENABLED(CONFIG_VLAN_8021Q)
>
> But here you should perhaps use IS_REACHABLE() otherwise when bnxt is
> built in and 8021q is a module there could be trouble, no?

I believe there shouldn't be trouble because the vlan_core code is
always builtin if CONFIG_VLAN_8021Q is m or y.  The symbols we need
are in vlan_core.
