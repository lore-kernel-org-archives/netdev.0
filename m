From: Ben Greear <greearb@candelatech.com>
Subject: Re: small change
Date: Tue, 28 Sep 2004 09:52:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <415996DC.4030509@candelatech.com>
References: <BB6D74C75CC76A419B6D6FA7C38317B23CEF03@sinett-sbs.SiNett.LAN>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Vishwas Manral <Vishwas@sinett.com>,
        "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
In-Reply-To: <BB6D74C75CC76A419B6D6FA7C38317B23CEF03@sinett-sbs.SiNett.LAN>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Vishwas Manral wrote:
> Hi Ben,
> 
> I am going through the 2.4 code. We can make small changes in br_input.c
> to make the code slightly better and slightly more optimized. Maybe when
> you are changing something else you can club it along.

Please send this to the netdev mailing list:

netdev@oss.sgi.com

I don't maintain the bridging code but there are people on
that list who do.

They would also prefer a unified diff instead of the cut-n-paste
like you sent.

Thanks,
Ben


> 
> Thanks,
> Vishwas
> 
> ========================================================================
> =======
> Change from ->
> 
>  87         if (dst != NULL && dst->is_local) {
>  88                 if (!passedup)
>  89                         br_pass_frame_up(br, skb);
>  90                 else
>  91                         kfree_skb(skb);
>  92                 br_fdb_put(dst);
>  93                 goto out;
>  94         }
>  95 
>  96         if (dst != NULL) {
>  97                 br_forward(dst->dst, skb);
>  98                 br_fdb_put(dst);
>  99                 goto out;
> 100         }
> 
> To ->
> 
>  87         if (dst != NULL) {
>                 if(dst->is_local) {
>  88                 if (!passedup)
>  89                         br_pass_frame_up(br, skb);
>  90                 else
>  91                         kfree_skb(skb);
>                  } else {
>  97                 br_forward(dst->dst, skb);
>                  }
>  92              br_fdb_put(dst);
>  93              goto out;
>  94         }
> 
> 


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
