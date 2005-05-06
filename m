From: jamal <hadi@cyberus.ca>
Subject: Re: [NET]: Avoid useless iterating in netlink dump functions
Date: Fri, 06 May 2005 17:04:33 -0400
Message-ID: <1115413473.13922.38.camel@localhost.localdomain>
References: <427B8FC3.4000305@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Maillist netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <427B8FC3.4000305@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Fri, 2005-06-05 at 17:39 +0200, Patrick McHardy wrote:
> This patch changes a couple of places like this:
> 
>        for (h = 0; h <= tbl->hash_mask; h++) {
>                if (h < s_h)
>                        continue;
> 
> to this:
> 
>        for (h = s_h; h <= tbl->hash_mask; h++) {
> 
> The only difference is that we can now get past the loop with
> h > tbl->hash_mask if hash_mask was decreased between two callbacks
> and h was already past the new value. But it still behaves identical,
> nothing is dumped.
> 

Looks good - you may also wanna treat tcf_dump_walker() and
xfrm_dump_sa() the same way then. 

cheers,
jamal
