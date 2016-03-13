From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH next v2 0/7] Introduce l3_dev pointer for L3 processing
Date: Sun, 13 Mar 2016 16:44:01 -0700
Message-ID: <CAF2d9jiippF_V-JYSAV8vJjU8f2wtDZVLoZ7n5BZJkct5L0Cbg@mail.gmail.com>
References: <1457560189-12870-1-git-send-email-mahesh@bandewar.net> <56E14296.5010103@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f180.google.com ([209.85.161.180]:33763 "EHLO
	mail-yw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752997AbcCMXoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 19:44:22 -0400
Received: by mail-yw0-f180.google.com with SMTP id d65so148892651ywb.0
        for <netdev@vger.kernel.org>; Sun, 13 Mar 2016 16:44:22 -0700 (PDT)
In-Reply-To: <56E14296.5010103@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> If I understand correctly (and as Cong already said), information are
> leaking
> between netns during the input phase. On the tx side, skb_scrub_packet() is
> called, but not on the rx side. I think it's wrong. There should be an
> explicit
> boundary.
>
I think we used to do dev_forward_skb() in the RX path which used to
do skb_scrub_packet().
When we added the optimization to avoid queuing second time just to
deliver packet to the
slave (by doing RX_HANDLER_ANOTHER), we lost the skb_scrub_packet()
which we used to
get automatically. I believe we can add that! Thanks for pointing it out.

> Another small comment: maybe finding another name than l3_dev could help to
> avoid confusion with the existing l3mdev.
I have absolutely no preference for the name. I used it to indicate
this is the *L3 device*.
Please suggest.
