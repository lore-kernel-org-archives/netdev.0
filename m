From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3] net: fs_enet: merge NAPI RX and NAPI TX
Date: Wed, 24 Aug 2016 06:15:49 -0700
Message-ID: <1472044549.14381.73.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1472033140.git.christophe.leroy@c-s.fr>
         <c607324b1322bb5729081808b2f54f5f9da52444.1472033140.git.christophe.leroy@c-s.fr>
         <1472044021.14381.71.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pantelis Antoniou <pantelis.antoniou@gmail.com>,
        Vitaly Bordug <vbordug@ru.mvista.com>, davem@davemloft.net,
        linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org
To: Christophe Leroy <christophe.leroy@c-s.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472044021.14381.71.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-08-24 at 06:07 -0700, Eric Dumazet wrote:

> I am afraid you could live lock here on SMP.
> 
> You should make sure you do not loop forever, not assuming cpu is faster
> than NIC.

You are protected by the tx_lock spinlock, but this is fragile as you
could very well remove this spinlock in the future to get lockless
transmit, like many other drivers.
