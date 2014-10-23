From: Ilya Dryomov <ilya.dryomov@inktank.com>
Subject: Re: [PATCH 1/1 net-next] libceph: remove unused variable in handle_reply()
Date: Thu, 23 Oct 2014 20:25:35 +0400
Message-ID: <CALFYKtD222g32njwF8nHz0Fbjj4p2512ka9bkADmB6S2QibgYA@mail.gmail.com>
References: <1414080959-6053-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Sage Weil <sage@inktank.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ceph Development <ceph-devel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Fabian Frederick <fabf@skynet.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1414080959-6053-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 23, 2014 at 8:15 PM, Fabian Frederick <fabf@skynet.be> wrote:
> osdmap_epoch is redundant with reassert_epoch and unused.
>
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> ---
>  net/ceph/osd_client.c | 2 --
>  1 file changed, 2 deletions(-)
>
> diff --git a/net/ceph/osd_client.c b/net/ceph/osd_client.c
> index f3fc54e..432bd75 100644
> --- a/net/ceph/osd_client.c
> +++ b/net/ceph/osd_client.c
> @@ -1700,7 +1700,6 @@ static void handle_reply(struct ceph_osd_client *osdc, struct ceph_msg *msg,
>         int err;
>         u32 reassert_epoch;
>         u64 reassert_version;
> -       u32 osdmap_epoch;
>         int already_completed;
>         u32 bytes;
>         unsigned int i;
> @@ -1725,7 +1724,6 @@ static void handle_reply(struct ceph_osd_client *osdc, struct ceph_msg *msg,
>         result = ceph_decode_32(&p);
>         reassert_epoch = ceph_decode_32(&p);
>         reassert_version = ceph_decode_64(&p);
> -       osdmap_epoch = ceph_decode_32(&p);
>
>         /* lookup */
>         down_read(&osdc->map_sem);

Hi Fabian,

osdmap_epoch is useful for debugging, but this is wrong anyway -
ceph_decode_32() has side effects.  Removing it and not adjusting *p
would make the whole thing blow up pretty fast..

Thanks,

                Ilya
