From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH 2/9] PKT_SCHED: tc filter extension API
Date: Fri, 31 Dec 2004 00:04:29 -0200
Message-ID: <41D4B3AD.9080605@conectiva.com.br>
References: <20041230122652.GM32419@postel.suug.ch> <20041230123023.GO32419@postel.suug.ch> <41D4A4D2.4000109@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41D4A4D2.4000109@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Thomas Graf wrote:
> 
>> +int
>> +tcf_exts_validate(struct tcf_proto *tp, struct rtattr **tb,
>> +              struct rtattr *rate_tlv, struct tcf_exts *exts,
>> +              struct tcf_ext_map *map)
>> +{
>> +    memset(exts, 0, sizeof(*exts));
>> +   
>> +#ifdef CONFIG_NET_CLS_ACT
>> +    int err;
>> +    struct tc_action *act;
>> +
>> +    if (map->police && tb[map->police-1] && rate_tlv) {
>> +        act = tcf_action_init_1(tb[map->police-1], rate_tlv, "police",
>> +            TCA_ACT_NOREPLACE, TCA_ACT_BIND, &err);
>> +        if (NULL == act)
> 
> 
> Please use act == NULL

Agreed, but I understand the people who like this (ugly) style, it becomes
less likely to become an "if (act = NULL)", but hey, compilers already
helps us with a nice warning.

- Arnaldo
