From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next 0/2] handle_ing update
Date: Mon, 11 May 2015 15:03:51 -0700
Message-ID: <CAHA+R7Od3WWS+sM0cr7=4YEB4qMiY61dfrfH_+Eeayi=LxzEsw@mail.gmail.com>
References: <cover.1431203900.git.daniel@iogearbox.net>
	<20150510170550.GA4442@salvia>
	<20150511.110949.1369224056076525434.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:37486 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751423AbbEKWDw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 18:03:52 -0400
Received: by widdi4 with SMTP id di4so114790918wid.0
        for <netdev@vger.kernel.org>; Mon, 11 May 2015 15:03:51 -0700 (PDT)
In-Reply-To: <20150511.110949.1369224056076525434.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 11, 2015 at 8:09 AM, David Miller <davem@davemloft.net> wrote:
> There is no difference between having ingress qdisc hanging off of
> netdevice vs. the classifier list.  They both serve the same purpose
> and the change to use the classifier list merely removes one level
> of indirection.

With adding 8 bytes to each of the netdevice even when it doesn't
have ingress qdisc attached at all...

Also breaks the abstraction of Qdisc's which potentially breaks
existing or future code, since now we have two different *layers* to
hold tp_proto.

BTW, it should be protected by CONFIG_NET_SCH_INGRESS
rather than CONFIG_NET_CLS_ACT.

>
> I also am confident that the cost for non-users is equivalent before
> and after this patch series.  Or at least, it very much should be.

If people really cared about ingress qdisc, that spinlock should have
gone much earlier than in 4.x release, rather than waiting for me to
remind.
