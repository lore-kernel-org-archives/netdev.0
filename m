From: Abdelrhman Ahmed <ab@abahmed.com>
Subject: Re: [PATCH] net: Reset skb to network header in neigh_hh_output
Date: Wed, 26 Oct 2016 01:57:25 +0200
Message-ID: <157fe46f382.10e50a6d8188917.494328765811573491@abahmed.com>
References: <1579f7f0f4f.114457ec828613.4349884782265574217@abahmed.com> <1475874656.28155.268.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "davem" <davem@davemloft.net>, "netdev" <netdev@vger.kernel.org>,
        "linux-kernel" <linux-kernel@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475874656.28155.268.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > What is the issue you want to fix exactly ? 
 > Please describe the use case. 

When netfilter hook uses skb_push to add a specific header between network
header and hardware header.
For the first time(s) before caching hardware header, this header will be
removed / overwritten by hardware header due to resetting to network header.
After using the cached hardware header, this header will be kept as we do not
reset. I think this behavior is inconsistent, so we need to reset in both cases.

 > Otherwise, your fix is in fact adding a critical bug. 

Could you explain more as it's not clear to me?



 ---- On Fri, 07 Oct 2016 23:10:56 +0200 Eric Dumazet <eric.dumazet@gmail.com> wrote ---- 
 > On Fri, 2016-10-07 at 16:14 +0200, Abdelrhman Ahmed wrote: 
 > > When hardware header is added without using cached one, neigh_resolve_output 
 > > and neigh_connected_output reset skb to network header before adding it. 
 > > When cached one is used, neigh_hh_output does not reset the skb to network 
 > > header. 
 > >  
 > > The fix is to reset skb to network header before adding cached hardware header 
 > > to keep the behavior consistent in all cases. 
 >  
 > What is the issue you want to fix exactly ? 
 >  
 > Please describe the use case. 
 >  
 > I highly suggest you take a look at commit 
 >  
 > e1f165032c8bade3a6bdf546f8faf61fda4dd01c 
 > ("net: Fix skb_under_panic oops in neigh_resolve_output") 
 >  
 > Otherwise, your fix is in fact adding a critical bug. 
 >  
 >  
 > 
