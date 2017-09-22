From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 10/10] net: hns3: Add mqprio support when
 interacting with network stack
Date: Fri, 22 Sep 2017 18:03:22 +0200
Message-ID: <20170922160322.GB2005@nanopsycho.orion>
References: <1505992913-107256-1-git-send-email-linyunsheng@huawei.com>
 <1505992913-107256-11-git-send-email-linyunsheng@huawei.com>
 <20170922125541.GA2005@nanopsycho.orion>
 <59c51a37.a1c4df0a.ac4e2.8df0SMTPIN_ADDED_BROKEN@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        huangdaode <huangdaode@hisilicon.com>,
        "xuwei (O)" <xuwei5@hisilicon.com>,
        "Liguozhu (Kenneth)" <liguozhu@hisilicon.com>,
        "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        Gabriele Paoloni <gabriele.paoloni@huawei.com>,
        John Garry <john.garry@huawei.com>,
        Linuxarm <linuxarm@huawei.com>,
        Salil Mehta <salil.mehta@huawei.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: linyunsheng <linyunsheng@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <59c51a37.a1c4df0a.ac4e2.8df0SMTPIN_ADDED_BROKEN@mx.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fri, Sep 22, 2017 at 04:11:51PM CEST, linyunsheng@huawei.com wrote:
>Hi, Jiri
>
>>>- if (!tc) {
>>>+ if (if_running) {
>>>+ (void)hns3_nic_net_stop(netdev);
>>>+ msleep(100);
>>>+ }
>>>+
>>>+ ret = (kinfo->dcb_ops && kinfo->dcb_ops->>setup_tc) ?
>>>+ kinfo->dcb_ops->setup_tc(h, tc, prio_tc) : ->EOPNOTSUPP;
>
>>This is most odd. Why do you call dcb_ops from >ndo_setup_tc callback?
>>Why are you mixing this together? prio->tc mapping >can be done
>>directly in dcbnl
>
>Here is what we do in dcb_ops->setup_tc:
>Firstly, if current tc num is different from the tc num
>that user provide, then we setup the queues for each
>tc.
>
>Secondly, we tell hardware the pri to tc mapping that
>the stack is using. In rx direction, our hardware need
>that mapping to put different packet into different tc'
>queues according to the priority of the packet, then
>rss decides which specific queue in the tc should the
>packet goto.
>
>By mixing, I suppose you meant why we need the
>pri to tc infomation?

by mixing, I mean what I wrote. You are calling dcb_ops callback from
ndo_setup_tc callback. So you are mixing DCBNL subsystem and TC
subsystem. Why? Why do you need sch_mqprio? Why DCBNL is not enough for
all?



>I hope I did not misunderstand your question, thanks
>for your time reviewing.
