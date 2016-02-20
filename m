From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] unix_diag: fix incorrect sign extension in unix_lookup_by_ino
Date: Fri, 19 Feb 2016 16:21:14 -0800
Message-ID: <CAM_iQpX4c7v2HbMG7cPi3T=HTHeEGhEQTSNS6CxX0tY=7KA4Uw@mail.gmail.com>
References: <20160219012748.GA17251@altlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Dmitry V. Levin" <ldv@altlinux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160219012748.GA17251@altlinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 18, 2016 at 5:27 PM, Dmitry V. Levin <ldv@altlinux.org> wrote:
> The value passed by unix_diag_get_exact to unix_lookup_by_ino has type
> __u32, but unix_lookup_by_ino's argument ino has type int, which is not
> a problem yet.
> However, when ino is compared with sock_i_ino return value of type
> unsigned long, ino is sign extended to signed long, and this results
> to incorrect comparison on 64-bit architectures for inode numbers
> greater than INT_MAX.
>
> This bug was found by strace test suite.
>
> Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
> Cc: <stable@vger.kernel.org>

Fixes: 5d3cae8bc39d ("unix_diag: Dumping exact socket core")
Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks.
