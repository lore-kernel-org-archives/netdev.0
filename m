From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] vxlan: dont migrate permanent fdb entries during learn
Date: Sun, 11 Jun 2017 16:26:31 -0700
Message-ID: <CAJieiUis6KOeLX-ePVbDd5U=ePXonvnAcFo0zkL__aQasjHrmg@mail.gmail.com>
References: <1497221482-33473-1-git-send-email-roopa@cumulusnetworks.com> <20170611.190416.1443081184910537296.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Benc <jbenc@redhat.com>,
        "hannes@stressinduktion.org" <hannes@stressinduktion.org>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:33551 "EHLO
        mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751936AbdFKX0c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 19:26:32 -0400
Received: by mail-vk0-f46.google.com with SMTP id p62so42705813vkp.0
        for <netdev@vger.kernel.org>; Sun, 11 Jun 2017 16:26:32 -0700 (PDT)
In-Reply-To: <20170611.190416.1443081184910537296.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 11, 2017 at 4:04 PM, David Miller <davem@davemloft.net> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> Date: Sun, 11 Jun 2017 15:51:22 -0700
>
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This patch fixes vxlan_snoop to not move permanent fdb entries
>> on learn events. This is consistent with the bridge fdb
>> handling of permanent entries.
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> Is there an appropriate Fixes: tag by chance?

Just checked history. It has been that way since beginning of time.
Initial vxlan implementation (year 2012) allowed migration of any
entry via learn. A 2013 commit 26a41ae60438 ("vxlan: only migrate
dynamic FDB entries") tried to fix it, but it added a check for static
entries only (NUD_NOARP) and missed permanent entries (NUD_PERMANENT).

I think we can add:
Fixes: 26a41ae60438 ("vxlan: only migrate dynamic FDB entries")

I can re-spin with this Fixes tag.
