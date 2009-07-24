From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] net/bridge: use kobject_put to release kobject in
 br_add_if error path
Date: Fri, 24 Jul 2009 08:36:07 -0700
Message-ID: <20090724083607.6b91282d@nehalam>
References: <1248426392-30777-1-git-send-email-dfeng@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Xiaotian Feng <dfeng@redhat.com>
To: Xiaotian Feng <dfeng@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753143AbZGXPgd@vger.kernel.org>
In-Reply-To: <1248426392-30777-1-git-send-email-dfeng@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 24 Jul 2009 17:06:32 +0800
Xiaotian Feng <dfeng@redhat.com> wrote:

> kobject_init_and_add will alloc memory for kobj->name, so in br_add_if
> error path, simply use kobject_del will not free memory for kobj->name.
> Fix by using kobject_put instead, kobject_put will internally calls
> kobject_del and frees memory for kobj->name.
> 
> Signed-off-by: Xiaotian Feng <dfeng@redhat.com>
> ---
>  net/bridge/br_if.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index 8a96672..eb404dc 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -424,7 +424,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
>  err2:
>  	br_fdb_delete_by_port(br, p, 1);
>  err1:
> -	kobject_del(&p->kobj);
> +	kobject_put(&p->kobj);
>  err0:
>  	dev_set_promiscuity(dev, -1);
>  put_back:

I assume you tested this by doing something like adding two interfaces
with the same MAC address to a bridge.

Acked-by: Stephen Hemminger <shemminger@vyatta.com>

-- 
