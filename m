From: Amir Vadai <amir@vadai.me>
Subject: Re: [PATCH net-next V2 03/10] net/sched: Macro instead of
 CONFIG_NET_CLS_ACT ifdef
Date: Thu, 3 Mar 2016 21:51:41 +0200
Message-ID: <20160303195141.GA15037@office.Home>
References: <1457016960-27832-1-git-send-email-amir@vadai.me>
 <1457016960-27832-4-git-send-email-amir@vadai.me>
 <CAM_iQpV-4On99wn7=kZQeem=xZy5SV2GnKuoORGD4uzQw=H47w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36540 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753539AbcCCTr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 14:47:29 -0500
Received: by mail-wm0-f67.google.com with SMTP id l68so623473wml.3
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 11:47:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAM_iQpV-4On99wn7=kZQeem=xZy5SV2GnKuoORGD4uzQw=H47w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 03, 2016 at 09:45:28AM -0800, Cong Wang wrote:
> On Thu, Mar 3, 2016 at 6:55 AM, Amir Vadai <amir@vadai.me> wrote:
> > Introduce the macros tc_no_actions and tc_for_each_action to make code
> > clearer.
> >
> > Suggested-by: Jiri Pirko <jiri@mellanox.com>
> > Signed-off-by: Amir Vadai <amir@vadai.me>
> > ---
> >  include/net/act_api.h        | 21 ++++++++++++++++-----
> >  include/net/tc_act/tc_gact.h |  4 ++--
> >  2 files changed, 18 insertions(+), 7 deletions(-)
> >
> > diff --git a/include/net/act_api.h b/include/net/act_api.h
> > index 342be6c..2a19fe1 100644
> > --- a/include/net/act_api.h
> > +++ b/include/net/act_api.h
> > @@ -78,11 +78,6 @@ static inline void tcf_lastuse_update(struct tcf_t *tm)
> >                 tm->lastuse = now;
> >  }
> >
> > -#ifdef CONFIG_NET_CLS_ACT
> > -
> > -#define ACT_P_CREATED 1
> > -#define ACT_P_DELETED 1
> > -
> >  struct tc_action {
> >         void                    *priv;
> >         const struct tc_action_ops      *ops;
> > @@ -92,6 +87,11 @@ struct tc_action {
> >         struct tcf_hashinfo     *hinfo;
> >  };
> 
> You also expose struct tc_action out of CONFIG_NET_CLS_ACT,
> which you never mention in your changelog at all.
Yes - it was a mistake not to mention it in the changelog.

> 
> So why?
The struct will not be used, and without exposing it, the compiler will
complain on code like I have in patch 9/10 ("net/mlx5e: Support offload
cls_flower with drop action"):

static int parse_tc_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
			    u32 *action, u32 *flow_tag)
{
	const struct tc_action *a;

	if (tc_no_actions(exts))
		return -EINVAL;

	*flow_tag = MLX5_FS_DEFAULT_FLOW_TAG;
	*action = 0;

	tc_for_each_action(a, exts) {

[...]
