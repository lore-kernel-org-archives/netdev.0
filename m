From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched: use explicit size of struct tcmsg, remove
 need to declare tcm
Date: Mon, 18 Sep 2017 08:00:34 -0700
Message-ID: <1505746834.29839.17.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170918114038.29741-1-colin.king@canonical.com>
         <063D6719AE5E284EB5DD2968C1650D6DD007891E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Colin King' <colin.king@canonical.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>,
        "David S . Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:37845 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755028AbdIRPAi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 11:00:38 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD007891E@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-09-18 at 12:18 +0000, David Laight wrote:
> From: Colin King
> > Sent: 18 September 2017 12:41
> > Pointer tcm is being initialized and is never read, it is only being used
> > to determine the size of struct tcmsg.  Clean this up by removing
> > variable tcm and explicitly using the sizeof struct tcmsg rather than *tcm.
> > Cleans up clang warning:
> > 
> > warning: Value stored to 'tcm' during its initialization is never read
> > 
> > Signed-off-by: Colin Ian King <colin.king@canonical.com>
> > ---
> >  net/sched/sch_api.c | 3 +--
> >  1 file changed, 1 insertion(+), 2 deletions(-)
> > 
> > diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> > index c6deb74e3d2f..aa82116ed10c 100644
> > --- a/net/sched/sch_api.c
> > +++ b/net/sched/sch_api.c
> > @@ -1500,7 +1500,6 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
> >  	int s_idx, s_q_idx;
> >  	struct net_device *dev;
> >  	const struct nlmsghdr *nlh = cb->nlh;
> > -	struct tcmsg *tcm = nlmsg_data(nlh);
> >  	struct nlattr *tca[TCA_MAX + 1];
> >  	int err;
> > 
> > @@ -1510,7 +1509,7 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
> >  	idx = 0;
> >  	ASSERT_RTNL();
> > 
> > -	err = nlmsg_parse(nlh, sizeof(*tcm), tca, TCA_MAX, NULL, NULL);
> > +	err = nlmsg_parse(nlh, sizeof(struct tcmsg), tca, TCA_MAX, NULL, NULL);
> 
> Would sizeof(*nlmsg_data(nlh)) be cleaner??

Not really, since 

static inline void *nlmsg_data(const struct nlmsghdr *nlh)
{
...
}
