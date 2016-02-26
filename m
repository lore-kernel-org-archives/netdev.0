From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next PATCH v3 1/3] net: sched: consolidate offload decision
 in cls_u32
Date: Fri, 26 Feb 2016 09:39:47 -0800
Message-ID: <CAM_iQpVPa7Twx35K-VjR6X0DJ9wQuSeTrfFSZe8HWU_yJVj2UA@mail.gmail.com>
References: <20160226154858.5338.90569.stgit@john-Precision-Tower-5810>
	<20160226155349.5338.74615.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Daniel Borkmann <daniel@iogearbox.net>,
	simon.horman@netronome.com,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f174.google.com ([209.85.161.174]:35763 "EHLO
	mail-yw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422956AbcBZRjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 12:39:48 -0500
Received: by mail-yw0-f174.google.com with SMTP id g127so74762097ywf.2
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 09:39:48 -0800 (PST)
In-Reply-To: <20160226155349.5338.74615.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 26, 2016 at 7:53 AM, John Fastabend
<john.fastabend@gmail.com> wrote:
> The offload decision was originally very basic and tied to if the dev
> implemented the appropriate ndo op hook. The next step is to allow
> the user to more flexibly define if any paticular rule should be
> offloaded or not. In order to have this logic in one function lift
> the current check into a helper routine tc_should_offload().
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
>  include/net/pkt_cls.h |    5 +++++
>  net/sched/cls_u32.c   |    8 ++++----
>  2 files changed, 9 insertions(+), 4 deletions(-)
>
> diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
> index 2121df5..e64d20b 100644
> --- a/include/net/pkt_cls.h
> +++ b/include/net/pkt_cls.h
> @@ -392,4 +392,9 @@ struct tc_cls_u32_offload {
>         };
>  };
>
> +static inline bool tc_should_offload(struct net_device *dev)
> +{
> +       return dev->netdev_ops->ndo_setup_tc;
> +}
> +

These should be protected by CONFIG_NET_CLS_U32, no?
