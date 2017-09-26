From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH v2 2/2] ip_tunnel: add mpls over gre encapsulation
Date: Tue, 26 Sep 2017 12:31:17 -0700
Message-ID: <CAJieiUi2vezQjZKomJo-YWi+bd=fTgSS4YVxVcWdDyfetR5RFg@mail.gmail.com>
References: <cover.1506416988.git.amine.kherbouche@6wind.com>
 <c40295d24ec5207f5be695a2f888bfa840e2ef2c.1506416988.git.amine.kherbouche@6wind.com>
 <CAJieiUhJCgrykvLNEFaABg6MXKR=FhgbK=bCZF0_QrYFaeG2tw@mail.gmail.com> <9f0675b0-cbda-9053-250f-19f3f837b124@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>, xeb@mail.ru,
        David Lamparter <equinox@diac24.net>
To: Amine Kherbouche <amine.kherbouche@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f173.google.com ([209.85.217.173]:45565 "EHLO
        mail-ua0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030327AbdIZTbS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 15:31:18 -0400
Received: by mail-ua0-f173.google.com with SMTP id c27so7148308uah.2
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 12:31:18 -0700 (PDT)
In-Reply-To: <9f0675b0-cbda-9053-250f-19f3f837b124@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 26, 2017 at 10:58 AM, Amine Kherbouche
<amine.kherbouche@6wind.com> wrote:
> Hi Roopa,
>
> Thanks for the feedback, I have just one question:
>
>
> On 09/26/2017 05:15 PM, Roopa Prabhu wrote:
>>>
>>> +static int ipgre_tunnel_encap_add_mpls_ops(void)
>>> > +{
>>> > +       int ret = -1;
>>> > +
>>> > +#if IS_ENABLED(CONFIG_NET_IP_TUNNEL)
>>> > +       ret = ip_tunnel_encap_add_ops(&mpls_iptun_ops,
>>> > TUNNEL_ENCAP_MPLS);
>>> > +#endif
>>> > +
>>> > +       return ret;
>>> > +}
>>> > +
>>> > +static void ipgre_tunnel_encap_del_mpls_ops(void)
>>> > +{
>>> > +#if IS_ENABLED(CONFIG_NET_IP_TUNNEL)
>>> > +       ip_tunnel_encap_del_ops(&mpls_iptun_ops, TUNNEL_ENCAP_MPLS);
>>> > +#endif
>>> > +}
>>> > +
>>> >  static void rtmsg_lfib(int event, u32 label, struct mpls_route *rt,
>>> >                        struct nlmsghdr *nlh, struct net *net, u32
>>> > portid,
>>> >                        unsigned int nlm_flags);
>>> > @@ -2486,6 +2521,10 @@ static int __init mpls_init(void)
>>> >                       0);
>>> >         rtnl_register(PF_MPLS, RTM_GETNETCONF,
>>> > mpls_netconf_get_devconf,
>>> >                       mpls_netconf_dump_devconf, 0);
>>> > +       err = ipgre_tunnel_encap_add_mpls_ops();
>>> > +       if (err)
>>> > +               pr_err("Can't add mpls over gre tunnel ops\n");
>>> > +
>>
>> This will throw an error  if CONFIG_NET_IP_TUNNEL is not enabled.
>> Can you pls put the CONFIG_NET_IP_TUNNEL around
>> ipgre_tunnel_encap_add_mpls_ops ?
>
>
> You want the CONFIG_NET_IP_TUNNEL definition around the declaration of the
> function or when it's called ? or both ? (I can adjust the code for any
> case).

around the declaration like below....,

#if IS_ENABLED(CONFIG_NET_IP_TUNNEL)
static int ipgre_tunnel_encap_add_mpls_ops(void)
{
      return ip_tunnel_encap_add_ops(&mpls_iptun_ops,
                                                            TUNNEL_ENCAP_MPLS);
}

static void ipgre_tunnel_encap_del_mpls_ops(void)
{
      ip_tunnel_encap_del_ops(&mpls_iptun_ops, TUNNEL_ENCAP_MPLS);
}
#else
static int ipgre_tunnel_encap_add_mpls_ops(void)
{
      return 0
}

static void ipgre_tunnel_encap_del_mpls_ops(void)
{
}
#endif

thanks.
