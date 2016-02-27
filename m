From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v3 1/3] net: sched: consolidate offload decision
 in cls_u32
Date: Fri, 26 Feb 2016 20:24:17 -0800
Message-ID: <56D124F1.3070300@gmail.com>
References: <20160226154858.5338.90569.stgit@john-Precision-Tower-5810>	<20160226155349.5338.74615.stgit@john-Precision-Tower-5810> <CAM_iQpVPa7Twx35K-VjR6X0DJ9wQuSeTrfFSZe8HWU_yJVj2UA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Daniel Borkmann <daniel@iogearbox.net>,
	simon.horman@netronome.com,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33856 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755533AbcB0EYl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 23:24:41 -0500
Received: by mail-pa0-f41.google.com with SMTP id fy10so61098207pac.1
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 20:24:41 -0800 (PST)
In-Reply-To: <CAM_iQpVPa7Twx35K-VjR6X0DJ9wQuSeTrfFSZe8HWU_yJVj2UA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-26 09:39 AM, Cong Wang wrote:
> On Fri, Feb 26, 2016 at 7:53 AM, John Fastabend
> <john.fastabend@gmail.com> wrote:
>> The offload decision was originally very basic and tied to if the dev
>> implemented the appropriate ndo op hook. The next step is to allow
>> the user to more flexibly define if any paticular rule should be
>> offloaded or not. In order to have this logic in one function lift
>> the current check into a helper routine tc_should_offload().
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>  include/net/pkt_cls.h |    5 +++++
>>  net/sched/cls_u32.c   |    8 ++++----
>>  2 files changed, 9 insertions(+), 4 deletions(-)
>>
>> diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
>> index 2121df5..e64d20b 100644
>> --- a/include/net/pkt_cls.h
>> +++ b/include/net/pkt_cls.h
>> @@ -392,4 +392,9 @@ struct tc_cls_u32_offload {
>>         };
>>  };
>>
>> +static inline bool tc_should_offload(struct net_device *dev)
>> +{
>> +       return dev->netdev_ops->ndo_setup_tc;
>> +}
>> +
> 
> These should be protected by CONFIG_NET_CLS_U32, no?
> 

Its not necessary it is a completely general function and I only
lifted it out of cls_u32 so that the cls_flower classifier could
also use it.

I don't see the need off-hand to have it wrapped in an ORd ifdef
statement where its (CONFIG_NET_CLS_U32 | CONFIG_NET_CLS_X ...).
Any particular reason you were thnking it should be wrapped in ifdefs?

Thanks for taking a look at the patches.

.John
