From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: initialize msg.msg_flags in recvfrom
Date: Tue, 07 Mar 2017 06:26:40 -0800
Message-ID: <1488896800.9415.398.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170307135810.90371-1-glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, kcc@google.com, edumazet@google.com,
        davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Alexander Potapenko <glider@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170307135810.90371-1-glider@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2017-03-07 at 14:58 +0100, Alexander Potapenko wrote:
> KMSAN (KernelMemorySanitizer, a new error detection tool) reports use
> of uninitialized memory in put_cmsg()):

I would prefer that you do not put the stack trace in the changelog,
same for the reproducer since this has little value in understanding the
impact.

It looks like a false positive, but you do not say.

recvmsg() does not care about msg.msg_flags, only KMSAN.

(The important part is that msg.msg_control and msg.msg_controllen are
0)

Fine to avoid the false positive, but better be explicit in the
changelog and says there is no visible effect for this bug.

If there is a visible effect, please state so instead of technical
details.

We try to reduce S/N in the changelogs ;)

Thanks a lot !
