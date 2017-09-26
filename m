From: Amine Kherbouche <amine.kherbouche@6wind.com>
Subject: Re: [PATCH v2 2/2] ip_tunnel: add mpls over gre encapsulation
Date: Tue, 26 Sep 2017 19:58:21 +0200
Message-ID: <9f0675b0-cbda-9053-250f-19f3f837b124@6wind.com>
References: <cover.1506416988.git.amine.kherbouche@6wind.com>
 <c40295d24ec5207f5be695a2f888bfa840e2ef2c.1506416988.git.amine.kherbouche@6wind.com>
 <CAJieiUhJCgrykvLNEFaABg6MXKR=FhgbK=bCZF0_QrYFaeG2tw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, xeb@mail.ru,
        David Lamparter <equinox@diac24.net>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:45369 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966562AbdIZR6c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 13:58:32 -0400
Received: by mail-wm0-f51.google.com with SMTP id q124so10520445wmb.0
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 10:58:31 -0700 (PDT)
In-Reply-To: <CAJieiUhJCgrykvLNEFaABg6MXKR=FhgbK=bCZF0_QrYFaeG2tw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Roopa,

Thanks for the feedback, I have just one question:

On 09/26/2017 05:15 PM, Roopa Prabhu wrote:
>> +static int ipgre_tunnel_encap_add_mpls_ops(void)
>> > +{
>> > +       int ret = -1;
>> > +
>> > +#if IS_ENABLED(CONFIG_NET_IP_TUNNEL)
>> > +       ret = ip_tunnel_encap_add_ops(&mpls_iptun_ops, TUNNEL_ENCAP_MPLS);
>> > +#endif
>> > +
>> > +       return ret;
>> > +}
>> > +
>> > +static void ipgre_tunnel_encap_del_mpls_ops(void)
>> > +{
>> > +#if IS_ENABLED(CONFIG_NET_IP_TUNNEL)
>> > +       ip_tunnel_encap_del_ops(&mpls_iptun_ops, TUNNEL_ENCAP_MPLS);
>> > +#endif
>> > +}
>> > +
>> >  static void rtmsg_lfib(int event, u32 label, struct mpls_route *rt,
>> >                        struct nlmsghdr *nlh, struct net *net, u32 portid,
>> >                        unsigned int nlm_flags);
>> > @@ -2486,6 +2521,10 @@ static int __init mpls_init(void)
>> >                       0);
>> >         rtnl_register(PF_MPLS, RTM_GETNETCONF, mpls_netconf_get_devconf,
>> >                       mpls_netconf_dump_devconf, 0);
>> > +       err = ipgre_tunnel_encap_add_mpls_ops();
>> > +       if (err)
>> > +               pr_err("Can't add mpls over gre tunnel ops\n");
>> > +
> This will throw an error  if CONFIG_NET_IP_TUNNEL is not enabled.
> Can you pls put the CONFIG_NET_IP_TUNNEL around
> ipgre_tunnel_encap_add_mpls_ops ?

You want the CONFIG_NET_IP_TUNNEL definition around the declaration of 
the function or when it's called ? or both ? (I can adjust the code for 
any case).

> see CONFIG_INET checks in the rest of af_mpls as example.
> same for del_ops
>

Thanks,

Amine
