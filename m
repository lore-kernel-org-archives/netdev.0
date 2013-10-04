From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v3 net-next] fix unsafe set_memory_rw from softirq
Date: Thu, 3 Oct 2013 23:30:41 -0700
Message-ID: <CAADnVQJq7r-e=vQBcvMqxEkFVzMjn=EaZ99j2boPj+YJBAhKxw@mail.gmail.com>
References: <1380859875-31025-1-git-send-email-ast@plumgrid.com>
	<1380863798.3564.12.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	linux-arm-kernel@lists.infradead.org,
	linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f43.google.com ([209.85.128.43]:38208 "EHLO
	mail-qe0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935Ab3JDGam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 02:30:42 -0400
In-Reply-To: <1380863798.3564.12.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 3, 2013 at 10:16 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2013-10-03 at 21:11 -0700, Alexei Starovoitov wrote:
>
> -static inline unsigned int sk_filter_len(const struct sk_filter *fp)
> +static inline unsigned int sk_filter_size(const struct sk_filter *fp,
> +                                         unsigned int proglen)
>  {
> -       return fp->len * sizeof(struct sock_filter) + sizeof(*fp);
> +       return max(sizeof(*fp),
> +                  offsetof(struct sk_filter, insns[proglen]));
>  }

indeed that's cleaner.
Like this then:
-static inline unsigned int sk_filter_len(const struct sk_filter *fp)
+static inline unsigned int sk_filter_size(unsigned int proglen)
 {
-       return fp->len * sizeof(struct sock_filter) + sizeof(*fp);
+       return max(sizeof(struct sk_filter),
+                  offsetof(struct sk_filter, insns[proglen]));
 }

testing it... will send v4 shortly
