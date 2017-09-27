From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [next-queue PATCH 2/3] net/sched: Introduce Credit Based Shaper
 (CBS) qdisc
Date: Wed, 27 Sep 2017 13:23:22 -0700
Message-ID: <CAM_iQpVrz+e=TYHYqaYyUWRP528GSZXx8EnN1yPhZK8eLvP4Yw@mail.gmail.com>
References: <20170926233916.11774-1-vinicius.gomes@intel.com> <20170926233916.11774-3-vinicius.gomes@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>, andre.guedes@intel.com,
        ivan.briano@intel.com, jesus.sanchez-palencia@intel.com,
        boon.leong.ong@intel.com, richardcochran@gmail.com,
        henrik@austad.us
To: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34058 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751663AbdI0UXn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 16:23:43 -0400
Received: by mail-pg0-f65.google.com with SMTP id u18so10299403pgo.1
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 13:23:43 -0700 (PDT)
In-Reply-To: <20170926233916.11774-3-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 26, 2017 at 4:39 PM, Vinicius Costa Gomes
<vinicius.gomes@intel.com> wrote:
> +static int cbs_init(struct Qdisc *sch, struct nlattr *opt)
> +{
> +       struct cbs_sched_data *q = qdisc_priv(sch);
> +       struct net_device *dev = qdisc_dev(sch);
> +
> +       if (!opt)
> +               return -EINVAL;
> +
> +       /* FIXME: this means that we can only install this qdisc
> +        * "under" mqprio. Do we need a more generic way to retrieve
> +        * the queue, or do we pass the netdev_queue to the driver?
> +        */
> +       q->queue = TC_H_MIN(sch->parent) - 1 - netdev_get_num_tc(dev);
> +
> +       return cbs_change(sch, opt);
> +}

Yeah it is ugly to assume its parent is mqprio, at least you should
error out if it is not the case.

I am not sure how we can solve this elegantly, perhaps you should
extend mqprio rather than add a new one?
