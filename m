From: Ilya Dryomov <idryomov@gmail.com>
Subject: Re: [PATCH] libceph: use kvfree() in ceph_put_page_vector()
Date: Mon, 1 Jun 2015 18:03:18 +0300
Message-ID: <CAOi1vP9k4UUJ_Dus6xpN+7GGEA=X4SbaD3WxHy5cVE9S8WtmYA@mail.gmail.com>
References: <1433169361-18667-1-git-send-email-geliangtang@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Yan, Zheng" <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ceph Development <ceph-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Geliang Tang <geliangtang@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433169361-18667-1-git-send-email-geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 1, 2015 at 5:36 PM, Geliang Tang <geliangtang@163.com> wrote:
> Use kvfree() instead of open-coding it.
>
> Signed-off-by: Geliang Tang <geliangtang@163.com>
> ---
>  net/ceph/pagevec.c | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
>
> diff --git a/net/ceph/pagevec.c b/net/ceph/pagevec.c
> index 096d914..d4f5f22 100644
> --- a/net/ceph/pagevec.c
> +++ b/net/ceph/pagevec.c
> @@ -51,10 +51,7 @@ void ceph_put_page_vector(struct page **pages, int num_pages, bool dirty)
>                         set_page_dirty_lock(pages[i]);
>                 put_page(pages[i]);
>         }
> -       if (is_vmalloc_addr(pages))
> -               vfree(pages);
> -       else
> -               kfree(pages);
> +       kvfree(pages);
>  }
>  EXPORT_SYMBOL(ceph_put_page_vector);

Already fixed in testing, wasn't pushed to linux-next though, sorry!

Thanks,

                Ilya
