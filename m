From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v4] net: don't call strlen() on the user buffer in packet_bind_spkt()
Date: Wed, 1 Mar 2017 21:13:02 -0800
Message-ID: <CAM_iQpWks1E0vGGTSsEn0a6mVy+gNRtqW3p42ik7AfcH1w4MdQ@mail.gmail.com>
References: <20170301115720.99985-1-glider@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Alexander Potapenko <glider@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170301115720.99985-1-glider@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 1, 2017 at 3:57 AM, Alexander Potapenko <glider@google.com> wrote:
> This happens because addr.sa_data copied from the userspace is not
> zero-terminated, and copying it with strlcpy() in packet_bind_spkt()
> results in calling strlen() on the kernel copy of that non-terminated
> buffer.

Very similar to

commit b301f2538759933cf9ff1f7c4f968da72e3f0757
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Thu Mar 24 21:29:53 2016 +0100

    netfilter: x_tables: enforce nul-terminated table name from
getsockopt GET_ENTRIES
