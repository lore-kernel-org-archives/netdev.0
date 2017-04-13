From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next RFC] Generic XDP
Date: Thu, 13 Apr 2017 11:38:26 -0400 (EDT)
Message-ID: <20170413.113826.446126425559844668.davem@davemloft.net>
References: <20170412.145415.1441440342830198148.davem@davemloft.net>
        <CACKFLikqDDLDSywxTNJoktpO0ViggH=Lbzebw27RaUPSGp0knQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xdp-newbies@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60564 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751003AbdDMPi1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 11:38:27 -0400
In-Reply-To: <CACKFLikqDDLDSywxTNJoktpO0ViggH=Lbzebw27RaUPSGp0knQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Wed, 12 Apr 2017 23:48:22 -0700

> On Wed, Apr 12, 2017 at 11:54 AM, David Miller <davem@davemloft.net> wrote:
>>
>> +static struct static_key generic_xdp_needed __read_mostly;
>> +
>> +static int generic_xdp_install(struct net_device *dev, struct netdev_xdp *xdp)
>> +{
>> +       struct bpf_prog *new = xdp->prog;
>> +       int ret = 0;
>> +
>> +       switch (xdp->command) {
>> +       case XDP_SETUP_PROG: {
>> +               struct bpf_prog *old = rtnl_dereference(dev->xdp_prog);
>> +
>> +               rcu_assign_pointer(dev->xdp_prog, new);
>> +               if (old)
>> +                       bpf_prog_put(old);
>> +
>> +               if (old && !new)
>> +                       static_key_slow_dec(&generic_xdp_needed);
>> +               else if (new && !old)
>> +                       static_key_slow_inc(&generic_xdp_needed);
> 
> I think we need to call dev_disable_lro(dev) to disable LRO also when
> a BPF program is installed.

Agreed, I'll add this.

Thanks Michael.
