From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] net: sched: fix refcount imbalance in actions
Date: Thu, 30 Jul 2015 11:48:28 -0700
Message-ID: <CAHA+R7NOZadKESRmSZpWxmdG9wRg+15cHbc5H_zUgp77zofPZA@mail.gmail.com>
References: <00f17fd2908b742c7e450bb76a1d487c0b32304f.1438205044.git.daniel@iogearbox.net>
	<CAHA+R7MVFhv1_J=0QE6zjCiVtCCKsaU=WgX6eH-u3op7GLZW5w@mail.gmail.com>
	<55B9760B.10004@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f169.google.com ([209.85.160.169]:33041 "EHLO
	mail-yk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651AbbG3Ss3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 14:48:29 -0400
Received: by ykdv124 with SMTP id v124so690394ykd.0
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 11:48:28 -0700 (PDT)
In-Reply-To: <55B9760B.10004@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 29, 2015 at 5:55 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> Hm, so this seems not correct: if we only ever increase tcfc_refcnt
> when there's bind=1, and only ever decrease when bind=1, then we
> will never free the action as we do start out from ref=1 in case
> it has been added without initial binding, if I see this correctly.
>

Right, I think your patch should be fine for net. The code is kinda messy,
but we can always clean up the logic for net-next.

Reviewed-by: Cong Wang <cwang@twopensource.com>

(It looks like mirred doesn't handle bind == true case correctly, I will send a
separated for it after your patch.)

Thanks.
