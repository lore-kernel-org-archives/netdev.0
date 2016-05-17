From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: linux-4.6/net/kcm/kcmsock.c:1508: bad if test ?
Date: Tue, 17 May 2016 09:04:21 -0700
Message-ID: <CAM_iQpWi4L-Dz92ce_nfvXJujEDKnmy_d6Ytsd0hLokvsSV3eA@mail.gmail.com>
References: <CAMzoambRTmpCmM0upiM5PMZtEioSMpw3QB4k--OCvHKmhCnw7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, dcb314@hotmail.com
To: David Binderman <linuxdev.baldrick@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMzoambRTmpCmM0upiM5PMZtEioSMpw3QB4k--OCvHKmhCnw7w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 16, 2016 at 11:40 AM, David Binderman
<linuxdev.baldrick@gmail.com> wrote:
> Hello there,
>
> linux-4.6/net/kcm/kcmsock.c:1508]: (style) Checking if unsigned
> variable 'copied' is less than zero.
>
> Source code is
>
>     if (copied < 0) {
>
> but
>
>    size_t copied;
>
> Suggest code rework.

Thanks for the report! I think the following patch is enough:

diff --git a/net/kcm/kcmsock.c b/net/kcm/kcmsock.c
index 40662d73..8bfc390 100644
--- a/net/kcm/kcmsock.c
+++ b/net/kcm/kcmsock.c
@@ -1483,7 +1483,7 @@ static ssize_t kcm_splice_read(struct socket
*sock, loff_t *ppos,
        long timeo;
        struct kcm_rx_msg *rxm;
        int err = 0;
-       size_t copied;
+       int copied;
        struct sk_buff *skb;

        /* Only support splice for SOCKSEQPACKET */
