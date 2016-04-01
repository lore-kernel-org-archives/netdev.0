From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC PATCH net 3/4] ipv6: datagram: Update dst cache of a
 connected datagram sk during pmtu update
Date: Fri, 1 Apr 2016 16:13:41 -0700
Message-ID: <CAM_iQpVeOKtTJ=oc9z6=SEaHDBTfpaPLKa-43TH1b_A3+TdWwA@mail.gmail.com>
References: <1459551391-69969-1-git-send-email-kafai@fb.com>
	<1459551391-69969-4-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Wei Wang <weiwan@google.com>, Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.161.179]:36557 "EHLO
	mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254AbcDAXNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 19:13:42 -0400
Received: by mail-yw0-f179.google.com with SMTP id g3so192582731ywa.3
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 16:13:41 -0700 (PDT)
In-Reply-To: <1459551391-69969-4-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 1, 2016 at 3:56 PM, Martin KaFai Lau <kafai@fb.com> wrote:
> +       bh_lock_sock(sk);
> +       if (!sock_owned_by_user(sk))
> +               ip6_datagram_dst_update(sk, false);
> +       bh_unlock_sock(sk);


My discussion with Eric shows that we probably don't need to hold
this sock lock here, and you are Cc'ed in that thread, so

1) why do you still take the lock here?
2) why didn't you involve in our discussion if you disagree?
