From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next] bridge: fix the unbalanced
 promiscuous count when add_if failed
Date: Thu, 29 May 2014 09:30:55 -0400
Message-ID: <5387368F.2080509@redhat.com>
References: <53869842.4060202@huawei.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev <netdev@vger.kernel.org>,
	bridge@lists.linux-foundation.org
To: Wang Weidong <wangweidong1@huawei.com>, David Miller <davem@davemloft.net>,
	stephen@networkplumber.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <53869842.4060202@huawei.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 05/28/2014 10:15 PM, Wang Weidong wrote:
> As commit 2796d0c648c94("bridge: Automatically manage port
> promiscuous mode."), make the add_if use dev_set_allmulti
> instead of dev_set_promiscuous, so when add_if failed, we
> should do dev_set_allmulti(dev, -1).
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Acked-by: Vlad Yasevich <vyasevic@redhat.com>

Thanks
-vlad

> ---
>  net/bridge/br_if.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index 104a811..a08d2b8 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -528,7 +528,7 @@ err2:
>  	kobject_put(&p->kobj);
>  	p = NULL; /* kobject_put frees */
>  err1:
> -	dev_set_promiscuity(dev, -1);
> +	dev_set_allmulti(dev, -1);
>  put_back:
>  	dev_put(dev);
>  	kfree(p);
> 
