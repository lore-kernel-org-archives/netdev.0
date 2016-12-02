From: "Lino Sanfilippo" <LinoSanfilippo@gmx.de>
Subject: Aw: Re: stmmac ethernet in kernel 4.9-rc6: coalescing related
 pauses.
Date: Fri, 2 Dec 2016 15:05:21 +0100
Message-ID: <trinity-11729d3e-ae5e-4850-a1bf-b83a1d0a864c-1480687521037@3capp-gmx-bs55>
References: <20161123105125.GA26394@amd> <20161124085506.GA25007@amd>
 <20161124.110416.198867271899443489.davem@davemloft.net>
 <20161124212540.GA24796@amd> <b6ac7a3c-6774-9568-1cc0-97074eaa928f@st.com>,
 <20161202084511.GA32294@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Giuseppe CAVALLARO" <peppe.cavallaro@st.com>,
        alexandre.torgue@st.com, "David Miller" <davem@davemloft.net>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Pavel Machek" <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161202084511.GA32294@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,


> 
> There's nothing that protect stmmac_poll() from running concurently
> with stmmac_dma_interrupt(), right?
> 

could it be that there is also another issue concerned locking?:
The tx completion handler takes the xmit_lock in case that the
netif_queue is stopped. This is AFAICS unnecessary, since both
xmit and completion handler are already synchronized by the private
tx lock. But it is IMHO also dangerous:

In the xmit handler we have the locking order
1. xmit_lock
2. private tx lock

while in the completion handler its the reverse:

1. private tx lock
2. xmit lock.

Do I miss something?


Regards,
Lino
