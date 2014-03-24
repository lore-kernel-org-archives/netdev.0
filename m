From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] ip_tunnel: Fix dst ref-count.
Date: Mon, 24 Mar 2014 12:36:41 -0700
Message-ID: <CALnjE+rzAs4Wr=pmozyPAr=T3QHE=-8qRBf-U_fHMDqeWAE+GA@mail.gmail.com>
References: <1395637596-28064-1-git-send-email-pshelar@nicira.com>
	<20140324.152412.1501867662024898167.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, lucien xin <lucien.xin@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:45524 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754319AbaCXTgm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 15:36:42 -0400
Received: by mail-ve0-f174.google.com with SMTP id oz11so6110126veb.19
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 12:36:41 -0700 (PDT)
In-Reply-To: <20140324.152412.1501867662024898167.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 24, 2014 at 12:24 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin <pshelar@nicira.com>
> Date: Sun, 23 Mar 2014 22:06:36 -0700
>
>> Commit 10ddceb22ba (ip_tunnel:multicast process cause panic due
>> to skb->_skb_refdst NULL pointer) removed dst-drop call from
>> ip-tunnel-recv.
>>
>> Following commit reintroduce dst-drop and fix the original bug by
>> checking loopback packet before releasing dst.
>> Original bug: https://bugzilla.kernel.org/show_bug.cgi?id=70681
>>
>> CC: Xin Long <lucien.xin@gmail.com>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>
> I don't understand why only the GRE tunnel implementation needs the
> check, whereas ipip and sit seem to have the same code associated
> paths.
>
Multicast support is for GRE. The code is always been protected by
CONFIG_NET_IPGRE_BROADCAST. So I do not understand how this applies to
other tunnel protocol. Can you point me to the code you are worried
about?

> Plus I think this is incredibly sloppy, making the implementations
> have to attend to this detail.  Why the heck do we have a common
> piece of infrastructure if we end up with all of this duplicated
> code anyways?
>
> Put this check somewhere common, so that we are guaranteed that the
> issue is really fixed for all tunnel types, no matter what.
>
> Thanks.
