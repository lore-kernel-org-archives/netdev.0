From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH v4 net-next 2/2] tc: add 'needs_l2' flag to ingress qdisc
Date: Mon, 13 Apr 2015 15:44:49 -0700
Message-ID: <CAHA+R7N1oPoZBgtF0WOa=aXveT4T=26yfL73Temdp+qWxkxfug@mail.gmail.com>
References: <CAHA+R7PqC=cfb+WTrBrQjNkio9-bWXX9mX43xcRism4qTNiGog@mail.gmail.com>
	<5528C4FC.5020207@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:36324 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431AbbDMWou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 18:44:50 -0400
Received: by wizk4 with SMTP id k4so91514858wiz.1
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 15:44:49 -0700 (PDT)
In-Reply-To: <5528C4FC.5020207@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 10, 2015 at 11:53 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 04/11/2015 02:45 AM, Cong Wang wrote:
> ...
>>
>> The problem you try to solve is kernel's implementation problem,
>> users should not care, so we should make some effort to make ingress
>> align with egress, rather than making more differences.
>
>
> I guess you've followed the previous discussion up to this point,
> and are aware that we cannot break some users f.e. such as u32.

This is not hard to fix, e.g. pull it back in u32 for egress.

> There has been thought put into this and we went back and forth,
> if you have a better suggestion on how to get it resolved properly
> and generically, I'm all for it.

My suggestion is fairly simple: move skb_pull() out of eth_type_trans()
and move it to netif_receive_skb(), it apparently needs much more work
but it worth the effort. This would eliminate the skb_push() in mirred
and in ifb too, dev_forward_skb() would benefit too.
