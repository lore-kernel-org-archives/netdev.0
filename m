From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH v3 net 1/2] net/sched: act_vlan: Push skb->data to
 mac_header prior calling skb_vlan_*() functions
Date: Thu, 29 Sep 2016 12:20:35 +0300
Message-ID: <20160929122035.56447ce2@halley>
References: <1475140241-23586-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Pravin Shelar <pshelar@ovn.org>, Jiri Pirko <jiri@mellanox.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:38024 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932451AbcI2JUo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 05:20:44 -0400
Received: by mail-wm0-f43.google.com with SMTP id w72so14062515wmf.1
        for <netdev@vger.kernel.org>; Thu, 29 Sep 2016 02:20:43 -0700 (PDT)
In-Reply-To: <1475140241-23586-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

On Thu, 29 Sep 2016 12:10:40 +0300 Shmulik Ladkani <shmulik.ladkani@gmail.com> wrote:
> This patch fixes act_vlan to point to the mac_header prior calling
> skb_vlan_*() functions, as other callers do.
> 

This 1/2 patch fixes the problem detailed in [1] for act_vlan,
last known caller of skb_vlan_*() with skb->data not at mac_header.

I think it's a good candidate for -stable; it fixes the observed bug and
it is rather focused.

Subsequent 2/2 patch hermetically seals the future possibility that one
might call skb_vlan_*() with skb->data not at mac_header.

This might go to stable as well, but not strictly required.

Thanks,
Shmulik

[1] https://patchwork.ozlabs.org/patch/676111/
