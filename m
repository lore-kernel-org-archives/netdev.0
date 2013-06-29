From: Dmitry Kravkov <dkravkov@gmail.com>
Subject: Re: [Patch net-next v3] gre: fix a regression in ioctl
Date: Sat, 29 Jun 2013 21:42:48 +0300
Message-ID: <CAM8tLiP=Y5BM7q3nGzi+J6JGRYTJ8qazpVB-n9+pFhA2ko-+sA@mail.gmail.com>
References: <CALnjE+qo33kqer_JQVwC+FDpmrSYpU2WkiYqeN6R11OWQkocug@mail.gmail.com>
	<1372478579-6548-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f181.google.com ([209.85.128.181]:45724 "EHLO
	mail-ve0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707Ab3F2Smt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 14:42:49 -0400
Received: by mail-ve0-f181.google.com with SMTP id db10so2688833veb.26
        for <netdev@vger.kernel.org>; Sat, 29 Jun 2013 11:42:48 -0700 (PDT)
In-Reply-To: <1372478579-6548-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 29, 2013 at 7:02 AM, Cong Wang <amwang@redhat.com> wrote:
> From: Cong Wang <amwang@redhat.com>
>
> When testing GRE tunnel, I got:
>
>  # ip tunnel show
>  get tunnel gre0 failed: Invalid argument
>  get tunnel gre1 failed: Invalid argument
>
> This is a regression introduced by commit c54419321455631079c7d
> ("GRE: Refactor GRE tunneling code.") because previously we
> only check the parameters for SIOCADDTUNNEL and SIOCCHGTUNNEL,
> after that commit, the check is moved for all commands.
>
> So, just check for SIOCADDTUNNEL and SIOCCHGTUNNEL.
>
> After this patch I got:
>
>  # ip tunnel show
>  gre0: gre/ip  remote any  local any  ttl inherit  nopmtudisc
>  gre1: gre/ip  remote 192.168.122.101  local 192.168.122.45  ttl inherit
>
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
> v2: check TUNNEL_* flags
> v3: the check should be kept in gre module
>

Shouldn't this be addressed in net-tree?
