From: Ilya Dryomov <idryomov@gmail.com>
Subject: Re: [PATCH 3/3] libceph: use KMEM_CACHE macro
Date: Tue, 22 Mar 2016 17:58:00 +0100
Message-ID: <CAOi1vP9UOwDKJG7hkpCxgCxXP6t3FO5z5PMSeZ8gKrf=w+_ddw@mail.gmail.com>
References: <9242267d62daeec8a0de5a1230f750ca486d62cd.1457853190.git.geliangtang@163.com>
	<a9c3e96ba6bf321ca13d9445d2770781fb7033cd.1457853190.git.geliangtang@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Yan, Zheng" <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ceph Development <ceph-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Geliang Tang <geliangtang@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f66.google.com ([209.85.215.66]:33764 "EHLO
	mail-lf0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755417AbcCVQ6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2016 12:58:03 -0400
In-Reply-To: <a9c3e96ba6bf321ca13d9445d2770781fb7033cd.1457853190.git.geliangtang@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 13, 2016 at 8:18 AM, Geliang Tang <geliangtang@163.com> wrote:
> Use KMEM_CACHE() instead of kmem_cache_create() to simplify the code.
>
> Signed-off-by: Geliang Tang <geliangtang@163.com>
> ---
>  net/ceph/messenger.c  | 10 ++--------
>  net/ceph/osd_client.c |  5 +----
>  2 files changed, 3 insertions(+), 12 deletions(-)
>
> diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
> index 9382619..32c997e 100644
> --- a/net/ceph/messenger.c
> +++ b/net/ceph/messenger.c
> @@ -235,18 +235,12 @@ static struct workqueue_struct *ceph_msgr_wq;
>  static int ceph_msgr_slab_init(void)
>  {
>         BUG_ON(ceph_msg_cache);
> -       ceph_msg_cache = kmem_cache_create("ceph_msg",
> -                                       sizeof (struct ceph_msg),
> -                                       __alignof__(struct ceph_msg), 0, NULL);
> -
> +       ceph_msg_cache = KMEM_CACHE(ceph_msg, 0);
>         if (!ceph_msg_cache)
>                 return -ENOMEM;
>
>         BUG_ON(ceph_msg_data_cache);
> -       ceph_msg_data_cache = kmem_cache_create("ceph_msg_data",
> -                                       sizeof (struct ceph_msg_data),
> -                                       __alignof__(struct ceph_msg_data),
> -                                       0, NULL);
> +       ceph_msg_data_cache = KMEM_CACHE(ceph_msg_data, 0);
>         if (ceph_msg_data_cache)
>                 return 0;
>
> diff --git a/net/ceph/osd_client.c b/net/ceph/osd_client.c
> index 5bc0537..7558855 100644
> --- a/net/ceph/osd_client.c
> +++ b/net/ceph/osd_client.c
> @@ -2783,10 +2783,7 @@ EXPORT_SYMBOL(ceph_osdc_writepages);
>  int ceph_osdc_setup(void)
>  {
>         BUG_ON(ceph_osd_request_cache);
> -       ceph_osd_request_cache = kmem_cache_create("ceph_osd_request",
> -                                       sizeof (struct ceph_osd_request),
> -                                       __alignof__(struct ceph_osd_request),
> -                                       0, NULL);
> +       ceph_osd_request_cache = KMEM_CACHE(ceph_osd_request, 0);
>
>         return ceph_osd_request_cache ? 0 : -ENOMEM;
>  }

Applied, with osd_client.c hunk dropped.  ceph_osd_request cache
objects are not longer sizeof(struct ceph_osd_request).

Thanks,

                Ilya
