From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] net: Handle negative checksum offset in skb-checksum-help
Date: Mon, 21 Sep 2015 18:04:14 -0700
Message-ID: <CALnjE+owCFib4oXD5zbJNRR9ZosT508tS=0_YL3UD1xg51hD3g@mail.gmail.com>
References: <1442818397-2210-1-git-send-email-pshelar@nicira.com>
	<20150921.171412.613695619204829336.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:35185 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756529AbbIVBEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 21:04:15 -0400
Received: by igbkq10 with SMTP id kq10so72118801igb.0
        for <netdev@vger.kernel.org>; Mon, 21 Sep 2015 18:04:15 -0700 (PDT)
In-Reply-To: <20150921.171412.613695619204829336.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 21, 2015 at 5:14 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin B Shelar <pshelar@nicira.com>
> Date: Sun, 20 Sep 2015 23:53:17 -0700
>
>> VXLAN device can receive skb with checksum partial. But the checksum
>> offset could be in outer header which is pulled on receive.
>
> Such a scenerio is a bug.
>
> Anything that pulls off a header should use a utility function such
> as skb_pull_rcsum() or skb_postpull_rcsum() to make sure this gets
> fixed up properly.

skb_postpull_rcsum() does not change checksum-offset. vxlan receive
already calls this function.
