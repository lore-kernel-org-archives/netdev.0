From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net 3/3] team: use a larger struct for mac address
Date: Wed, 26 Apr 2017 09:10:00 -0700
Message-ID: <CAM_iQpVZ2-GZ+M6VGhfF6yU2pE5E49u1emv7aAyU-9X81uOmQw@mail.gmail.com>
References: <1493183003-884-1-git-send-email-xiyou.wangcong@gmail.com>
 <1493183003-884-4-git-send-email-xiyou.wangcong@gmail.com> <20170426054033.GA1867@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35090 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750803AbdDZQKV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 12:10:21 -0400
Received: by mail-wm0-f68.google.com with SMTP id d79so2366510wmi.2
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 09:10:21 -0700 (PDT)
In-Reply-To: <20170426054033.GA1867@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 10:40 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Wed, Apr 26, 2017 at 07:03:23AM CEST, xiyou.wangcong@gmail.com wrote:
>>IPv6 tunnels use sizeof(struct in6_addr) as dev->addr_len,
>>but in many places especially bonding, we use struct sockaddr
>>to copy and set mac addr, this could lead to stack out-of-bounds
>>access.
>>
>>Fix it by using a larger address storage.
>>
>>Reported-by: Andrey Konovalov <andreyknvl@google.com>
>>Cc: Jiri Pirko <jiri@resnulli.us>
>>Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>>---
>> drivers/net/team/team.c | 9 ++++++---
>> 1 file changed, 6 insertions(+), 3 deletions(-)
>>
>>diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
>>index 85c0124..88878f1 100644
>>--- a/drivers/net/team/team.c
>>+++ b/drivers/net/team/team.c
>>@@ -60,10 +60,13 @@ static struct team_port *team_port_get_rtnl(const struct net_device *dev)
>> static int __set_port_dev_addr(struct net_device *port_dev,
>>                              const unsigned char *dev_addr)
>> {
>>-      struct sockaddr addr;
>>+      struct {
>>+              unsigned short type;
>>+              unsigned char addr[MAX_ADDR_LEN];
>>+      } addr;
>
> Wouldn't it make sense to define this struct somewhere in the core
> headers?

I _did_ use a struct mac_addr until I found there are multiple places
in the tree already defining it... We are in a similar situation to the union
of struct in_addr and struct in6_addr, unfortunately.

We can always clean up these for net-next.
