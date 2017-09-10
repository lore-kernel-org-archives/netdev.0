From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] netlink: access nlk groups safely in netlink bind and getname
Date: Sun, 10 Sep 2017 23:45:52 +1200
Message-ID: <CADvbK_dBm1b97eFqGrEp1EZN8Sfozm3PJ1MhqEZK+R3FB47-ZQ@mail.gmail.com>
References: <cfb5c05d158b278beb2f1441c67a068a8bb27d44.1504670009.git.lucien.xin@gmail.com>
 <CAM_iQpXA7q9_WADayWiHgqsz=VfhNqZr42TL0F+N2XK+toEEOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:36448 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751246AbdIJLpy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 10 Sep 2017 07:45:54 -0400
Received: by mail-qk0-f173.google.com with SMTP id z143so14102955qkb.3
        for <netdev@vger.kernel.org>; Sun, 10 Sep 2017 04:45:53 -0700 (PDT)
In-Reply-To: <CAM_iQpXA7q9_WADayWiHgqsz=VfhNqZr42TL0F+N2XK+toEEOQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 9, 2017 at 7:35 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Tue, Sep 5, 2017 at 8:53 PM, Xin Long <lucien.xin@gmail.com> wrote:
>> Now there is no lock protecting nlk ngroups/groups' accessing in
>> netlink bind and getname. It's safe from nlk groups' setting in
>> netlink_release, but not from netlink_realloc_groups called by
>> netlink_setsockopt.
>>
>> netlink_lock_table is needed in both netlink bind and getname when
>> accessing nlk groups.
>
> This looks very odd.
>
> netlink_lock_table() should be protecting nl_table, why
> it also protects nlk->groups?? For me it looks like you
> need lock_sock() instead.
I believe netlink_lock_table might be only used to protect nl_table
at the beginning and surely lock_sock is better here. Thanks.

But can you explain why  netlink_lock_table() was also used in
netlink_getsockopt NETLINK_LIST_MEMBERSHIPS ? or it
was just a mistake ?
