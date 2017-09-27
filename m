From: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
Subject: Re: [next-queue PATCH 2/3] net/sched: Introduce Credit Based Shaper
 (CBS) qdisc
Date: Wed, 27 Sep 2017 15:57:24 -0700
Message-ID: <4b0e1610-c9df-191d-496e-4be04c785d2f@intel.com>
References: <20170926233916.11774-1-vinicius.gomes@intel.com>
 <20170926233916.11774-3-vinicius.gomes@intel.com>
 <CAM_iQpVrz+e=TYHYqaYyUWRP528GSZXx8EnN1yPhZK8eLvP4Yw@mail.gmail.com>
 <87lgkzg7xv.fsf@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>, andre.guedes@intel.com,
        ivan.briano@intel.com, boon.leong.ong@intel.com,
        richardcochran@gmail.com, henrik@austad.us
To: Vinicius Costa Gomes <vinicius.gomes@intel.com>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:17613 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752231AbdI0XEW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 27 Sep 2017 19:04:22 -0400
In-Reply-To: <87lgkzg7xv.fsf@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


On 09/27/2017 02:14 PM, Vinicius Costa Gomes wrote:
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

What if we keep passing the index, but calculate it from the netdev_queue
pointer instead?

i.e.:  q->queue = sch->dev_queue - netdev_get_tx_queue(dev, 0);

At least it wouldn't rely on the root qdisc being of any specific type.

Regards,
Jesus
