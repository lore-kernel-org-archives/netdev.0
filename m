From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next V2 1/3] tun: abstract flow steering logic
Date: Thu, 2 Nov 2017 10:11:59 +0900
Message-ID: <CAF=yD-LP5kpAtL4KS2k4OjXdgy6Pe_YsUyYjW6zbCNmRzo_bdw@mail.gmail.com>
References: <1509445938-4345-1-git-send-email-jasowang@redhat.com> <1509445938-4345-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Tom Herbert <tom@herbertland.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1509445938-4345-2-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 31, 2017 at 7:32 PM, Jason Wang <jasowang@redhat.com> wrote:
> tun now use flow caches based automatic queue steering method. This
> may not suffice all user cases. To extend it to be able to use more
> flow steering policy, this patch abstracts flow steering logic into
> tun_steering_ops, then we can declare and use different methods in
> the future.
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/net/tun.c | 85 +++++++++++++++++++++++++++++++++++++++++--------------
>  1 file changed, 63 insertions(+), 22 deletions(-)
>
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index ea29da9..bff6259 100644

The previous RFC enabled support for multiple pluggable steering
policies. But as all can be implemented in BPF and we only plan to
support an eBPF policy besides the legacy one, this patch is no longer
needed. We can save a few indirect function calls.
