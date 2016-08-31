From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] rps: flow_dissector: Fix uninitialized flow_keys
 used in __skb_get_hash possibly
Date: Tue, 30 Aug 2016 21:14:50 -0700
Message-ID: <1472616890.14381.298.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472612179-23601-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, philipp@redfish-solutions.com,
        tom@herbertland.com, aduyck@mirantis.com, amir@vadai.me,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1472612179-23601-1-git-send-email-fgao@ikuai8.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-08-31 at 10:56 +0800, fgao@ikuai8.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
> 
> The original codes depend on that the function parameters are evaluated from
> left to right. But the parameter's evaluation order is not defined in C
> standard actually.
> 
> When flow_keys_have_l4(&keys) is invoked before ___skb_get_hash(skb, &keys,
> hashrnd) with some compilers or environment, the keys passed to
> flow_keys_have_l4 is not initialized.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>
> ---

Good catch, please add 

Fixes: 6db61d79c1e1 ("flow_dissector: Ignore flow dissector return value from ___skb_get_hash")
Acked-by: Eric Dumazet <edumazet@google.com>
