From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG() can be hit in tcp_collapse()
Date: Wed, 30 Nov 2016 09:33:01 -0800
Message-ID: <1480527181.18162.195.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1623420310.11961160.1478789246631.JavaMail.zimbra@redhat.com>
         <1478792652.8455.3.camel@edumazet-glaptop3.roam.corp.google.com>
         <1478805992.8455.20.camel@edumazet-glaptop3.roam.corp.google.com>
         <1478807366.8455.21.camel@edumazet-glaptop3.roam.corp.google.com>
         <1478808780.8455.23.camel@edumazet-glaptop3.roam.corp.google.com>
         <1716309808.12143903.1478869689618.JavaMail.zimbra@redhat.com>
         <1418136049.827916.1480525217226.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
        Marco Grassi <marco.gra@gmail.com>
To: Vladis Dronov <vdronov@redhat.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1418136049.827916.1480525217226.JavaMail.zimbra@redhat.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-11-30 at 12:00 -0500, Vladis Dronov wrote:
> Hello, Eric, Marco, all,
> 
> This is JFYI and a follow-up message.
> 
> A further investigation was made to find out the Linux kernel commit which has
> introduced the flaw. It appeared that previous Linux kernel versions are vulnerable,
> down to v3.6-rc1. This fact was hidden by 'net.ipv4.tcp_fastopen' set to 0 by default,
> and now it is easier to notice since kernel v3.12 due to commit 0d41cca490 where the
> default was changed to 1. With 'net.ipv4.tcp_fastopen' set to 1, previous Linux
> kernels (including RHEL-7 ones) are also vulnerable.
> 
> The bug is here since tcp-fastopen feature was introduced in kernel v3.6-rc1, the first
> commit when the reproducer starts to panic the kernel with net.ipv4.tcp_fastopen=1 set
> is cf60af03ca, which is a part of commit sequence 2100c8d2d9..67da22d23f introducing
> net-tcp-fastopen feature:
> 
> $ git bisect bad cf60af03ca4e71134206809ea892e49b92a88896
> cf60af03ca4e71134206809ea892e49b92a88896 is the first bad commit
> commit cf60af03ca4e71134206809ea892e49b92a88896
> Author: Yuchung Cheng <ycheng@google.com>
> Date:   Thu Jul 19 06:43:09 2012 +0000
> 
> So, ideally, the upstream commit ac6e780070 which fixes the bug should have
> "Fixes: cf60af03ca" statement, unfortunately, this investigation was not completed at
> the time the patch was accepted upstream. And unfortunately I do not see other way
> to add this information except making notes in a comment in the related code, which
> seems weird.

Well, the crash can happen way before Yuchung patch.

It is a 0-day bug.
