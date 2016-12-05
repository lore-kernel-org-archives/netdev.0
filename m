From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: ping: check minimum size on ICMP header length
Date: Mon, 05 Dec 2016 13:36:11 -0500 (EST)
Message-ID: <20161205.133611.650439526320620182.davem@davemloft.net>
References: <20161205183438.GA133528@beast>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchong@google.com, i@flanker017.me,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, linux-kernel@vger.kernel.org
To: keescook@chromium.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161205183438.GA133528@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kees Cook <keescook@chromium.org>
Date: Mon, 5 Dec 2016 10:34:38 -0800

> Prior to commit c0371da6047a ("put iov_iter into msghdr") in v3.19, there
> was no check that the iovec contained enough bytes for an ICMP header,
> and the read loop would walk across neighboring stack contents. Since the
> iov_iter conversion, bad arguments are noticed, but the returned error is
> EFAULT. Returning EINVAL is a clearer error and also solves the problem
> prior to v3.19.
> 
> This was found using trinity with KASAN on v3.18:
 ...
> CVE-2016-8399
> 
> Reported-by: Qidan He <i@flanker017.me>
> Fixes: c319b4d76b9e ("net: ipv4: add IPPROTO_ICMP socket kind")
> Cc: stable@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Applied and queued up for -stable, thanks.
