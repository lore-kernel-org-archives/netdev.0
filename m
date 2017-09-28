From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [next-queue PATCH 2/3] net/sched: Introduce Credit Based Shaper
 (CBS) qdisc
Date: Thu, 28 Sep 2017 15:34:47 -0700
Message-ID: <CAM_iQpUUUrYeyqYK-CDAXzuKcy9FDtq_etQQvO4D4uCjV6As-w@mail.gmail.com>
References: <20170926233916.11774-1-vinicius.gomes@intel.com>
 <20170926233916.11774-3-vinicius.gomes@intel.com> <CAM_iQpVrz+e=TYHYqaYyUWRP528GSZXx8EnN1yPhZK8eLvP4Yw@mail.gmail.com>
 <87lgkzg7xv.fsf@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>, andre.guedes@intel.com,
        Ivan Briano <ivan.briano@intel.com>,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com,
        richardcochran@gmail.com, Henrik Austad <henrik@austad.us>
To: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36060 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750832AbdI1WfI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 18:35:08 -0400
Received: by mail-pf0-f195.google.com with SMTP id f84so2606450pfj.3
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 15:35:07 -0700 (PDT)
In-Reply-To: <87lgkzg7xv.fsf@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 27, 2017 at 2:14 PM, Vinicius Costa Gomes
<vinicius.gomes@intel.com> wrote:
> Hi,
>
> Cong Wang <xiyou.wangcong@gmail.com> writes:
>
>> On Tue, Sep 26, 2017 at 4:39 PM, Vinicius Costa Gomes
>> <vinicius.gomes@intel.com> wrote:
>>> +static int cbs_init(struct Qdisc *sch, struct nlattr *opt)
>>> +{
>>> +       struct cbs_sched_data *q = qdisc_priv(sch);
>>> +       struct net_device *dev = qdisc_dev(sch);
>>> +
>>> +       if (!opt)
>>> +               return -EINVAL;
>>> +
>>> +       /* FIXME: this means that we can only install this qdisc
>>> +        * "under" mqprio. Do we need a more generic way to retrieve
>>> +        * the queue, or do we pass the netdev_queue to the driver?
>>> +        */
>>> +       q->queue = TC_H_MIN(sch->parent) - 1 - netdev_get_num_tc(dev);
>>> +
>>> +       return cbs_change(sch, opt);
>>> +}
>>
>> Yeah it is ugly to assume its parent is mqprio, at least you should
>> error out if it is not the case.
>
> Will add an error for this, for now.
>
>>
>> I am not sure how we can solve this elegantly, perhaps you should
>> extend mqprio rather than add a new one?
>
> Is the alternative hinted in the FIXME worse? Instead of passing the
> index of the hardware queue to the driver we pass the pointer to a
> netdev_queue to the driver and it "discovers" the HW queue from that.

Does this way solve the dependency on mqprio? If yes then it is good.
And you have to fix it before merge, we don't have any qdisc depending
a specific type of qdisc to be its parent.
