From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] fou: avoid using sk_user_data before it is initialised
Date: Wed, 18 May 2016 09:46:13 -0700
Message-ID: <CAM_iQpWfvcRMoXPsuOq6fi1TufzOYZWCg0FwpyDN2WNbTd3gmg@mail.gmail.com>
References: <1463560216-26616-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:33246 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753762AbcERQqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 12:46:40 -0400
Received: by mail-yw0-f194.google.com with SMTP id y6so7325530ywe.0
        for <netdev@vger.kernel.org>; Wed, 18 May 2016 09:46:38 -0700 (PDT)
In-Reply-To: <1463560216-26616-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 18, 2016 at 1:30 AM, Simon Horman
<simon.horman@netronome.com> wrote:
> During initialisation sk->sk_user_data should be initialised before
> it is referenced via a call to gue_encap_init().

Or just use 'fou' directly?

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index eeec7d6..0b7a983 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -453,7 +453,7 @@ static int fou_encap_init(struct sock *sk, struct
fou *fou, struct fou_cfg *cfg)
        udp_sk(sk)->encap_rcv = fou_udp_recv;
        udp_sk(sk)->gro_receive = fou_gro_receive;
        udp_sk(sk)->gro_complete = fou_gro_complete;
-       fou_from_sock(sk)->protocol = cfg->protocol;
+       fou->protocol = cfg->protocol;

        return 0;
 }
