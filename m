From: Jesse Gross <jesse@nicira.com>
Subject: Re: [ovs-dev] [PATCH net-next 1/2] openvswitch: add tunnel protocol
 to sw_flow_key
Date: Tue, 29 Sep 2015 19:08:44 -0700
Message-ID: <CAEP_g=_5EhyYeSNvitYSbNX9G52Kt=R6ruNz4V0uJK8sxPyYWQ@mail.gmail.com>
References: <cover.1443548447.git.jbenc@redhat.com> <428cee4cb7e04cfea5bef90b37d257562ea78a83.1443548447.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:35683 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750914AbbI3CJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 22:09:05 -0400
Received: by laer8 with SMTP id r8so29355062lae.2
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 19:09:03 -0700 (PDT)
In-Reply-To: <428cee4cb7e04cfea5bef90b37d257562ea78a83.1443548447.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 29, 2015 at 10:52 AM, Jiri Benc <jbenc@redhat.com> wrote:
> diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
> index 5c030a4d7338..03ba070c3256 100644
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
> @@ -643,6 +643,7 @@ static int ipv4_tun_from_nlattr(const struct nlattr *attr,
>         }
>
>         SW_FLOW_KEY_PUT(match, tun_key.tun_flags, tun_flags, is_mask);
> +       SW_FLOW_KEY_PUT(match, tun_proto, AF_INET, is_mask);

I don't think this is right in the case of the mask. It will cause the
the mask to be the value AF_INET - instead you want to set the mask to
be 0xff.
