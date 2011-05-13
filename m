From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 2/3] net/rfkill/core.c: Avoid leaving freed data in a
 list
Date: Fri, 13 May 2011 15:55:12 +0200
Message-ID: <1305294912.3468.0.camel@jlt3.sipsolutions.net>
References: <1305294731-12127-2-git-send-email-julia@diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305294731-12127-2-git-send-email-julia@diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-05-13 at 15:52 +0200, Julia Lawall wrote:
> The list_for_each_entry loop can fail, in which case the list element is
> not removed from the list rfkill_fds.  Since this list is not accessed by
> the loop, the addition of &data->list into the list is just moved after the
> loop.
> 
> The sematic match that finds this problem is as follows:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @@
> expression E,E1,E2;
> identifier l;
> @@
> 
> *list_add(&E->l,E1);
> ... when != E1
>     when != list_del(&E->l)
>     when != list_del_init(&E->l)
>     when != E = E2
> *kfree(E);// </smpl>
> 
> Signed-off-by: Julia Lawall <julia@diku.dk>
> 
> ---
> I have only verified that rfkill_fds is not accessed by the loop by
> inspecting the code.  If this analysis is not correct, the other solution
> would be to leave the list_add where it is and delete the element from the
> list explicitly.

Looks right to me, thanks!

johannes
