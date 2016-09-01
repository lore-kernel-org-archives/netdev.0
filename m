From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next V4 4/4] net/sched: Introduce act_tunnel_key
Date: Thu, 1 Sep 2016 16:58:18 +0300
Message-ID: <20160901165818.3dc6db4c@halley>
References: <1472647584-6713-1-git-send-email-hadarh@mellanox.com>
        <1472647584-6713-5-git-send-email-hadarh@mellanox.com>
        <20160831204456.46210aa2@halley>
        <CAJL1qvG54C5V-GzRqOKVhXjL7d1OUj5GuQvyx2vsKpQDdf_0Xg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@mellanox.com>,
        Jiri Benc <jbenc@redhat.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Tom Herbert <tom@herbertland.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>, Amir Vadai <amir@vadai.me>
To: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:35486 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753985AbcIAN6c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 09:58:32 -0400
Received: by mail-wm0-f42.google.com with SMTP id w2so78470513wmd.0
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 06:58:31 -0700 (PDT)
In-Reply-To: <CAJL1qvG54C5V-GzRqOKVhXjL7d1OUj5GuQvyx2vsKpQDdf_0Xg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 1 Sep 2016 14:59:28 +0300 Hadar Hen Zion <hadarh@dev.mellanox.co.il> wrote:
> > Seems we need to call tcf_hash_release regardless 'ovr':
> > In case (!exist), we've created a new hash few lines above.
> > Therefore in failure, don't we need a tcf_hash_release()?
> > Am I missing something?  
> 
> You are right, "if (ovr)" line should be removed.

Looking at it again, seems the right condition should be (pls verify):

		if (ret == ACT_P_CREATED)
			tcf_hash_release(*a, bind);

Thanks,
Shmulik
