From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RFC 1/3] tc: fix return values of ingress qdisc
Date: Tue, 21 Apr 2015 21:59:33 -0700
Message-ID: <CAHA+R7NwAdc81bFSoqvXsTpzod0vzT-PV38_Q0N0WTUVGFUY-g@mail.gmail.com>
References: <1429644476-8914-1-git-send-email-ast@plumgrid.com>
	<1429644476-8914-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:36304 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756082AbbDVE7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 00:59:35 -0400
Received: by wizk4 with SMTP id k4so163281936wiz.1
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2015 21:59:33 -0700 (PDT)
In-Reply-To: <1429644476-8914-2-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 21, 2015 at 12:27 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> ingress qdisc should return NET_XMIT_* values just like all other qdiscs.
>

XMIT already means egress...

> Since it's invoked via qdisc_enqueue_root() (which suppose to return
> only NET_XMIT_* values as well), it was working by accident,
> since TC_ACT_* values fit within NET_XMIT_MASK.
>

Why not just add a BUILD_BUG_ON() to capture this?
