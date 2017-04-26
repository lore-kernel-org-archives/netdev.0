From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: IGMP on IPv6
Date: Tue, 25 Apr 2017 22:24:58 -0700
Message-ID: <CAM_iQpVNGLzVd5KfwTeP9zXEUOR8yf00RsB8gd2RWn6bySOifg@mail.gmail.com>
References: <1479111388-25383-1-git-send-email-liuhangbin@gmail.com>
 <58D29265.1020604@ti.com> <58EFA913.5060604@ti.com> <CAM_iQpWYuQdxF0AOEMHRy7BSmxMVUb-7w7OdgYeOKe6atATsFQ@mail.gmail.com>
 <58F648FB.10606@ti.com> <58F64ADB.8040900@ti.com> <CAM_iQpWJ_oPSWV-PBeBGj5LoddMHTmrimLbViXLJ-VKR21e4mQ@mail.gmail.com>
 <58FF7656.8050506@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hangbin Liu <liuhangbin@gmail.com>,
        "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37780 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1949172AbdDZFZU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 01:25:20 -0400
Received: by mail-wm0-f54.google.com with SMTP id m123so114162751wma.0
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 22:25:19 -0700 (PDT)
In-Reply-To: <58FF7656.8050506@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 9:16 AM, Murali Karicheri <m-karicheri2@ti.com> wrote:
> On 04/18/2017 06:37 PM, Cong Wang wrote:
>> Did you assign IPv4 and IPv6 addresses to the HSR master device?
>
> No. I just used IPv4. From the trace mld_ifc_timer_expire() -> mld_sendpack() -> ip6_output()
> do you know what is it trying to do? Is it some neighbor discovery message or something
> going over the lower interface instead of the hsr interface?
>

IPv6 is special here because it has link-local address configured
automatically for each device, so this mld_ifc_timer is armed
for link-local multicasts. See:


 464         /* Join interface-local all-node multicast group */
 465         ipv6_dev_mc_inc(dev, &in6addr_interfacelocal_allnodes);
 466
 467         /* Join all-node multicast group */
 468         ipv6_dev_mc_inc(dev, &in6addr_linklocal_allnodes);
 469
 470         /* Join all-router multicast group if forwarding is set */
 471         if (ndev->cnf.forwarding && (dev->flags & IFF_MULTICAST))
 472                 ipv6_dev_mc_inc(dev, &in6addr_linklocal_allrouters);
