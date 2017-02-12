From: Eric Dumazet <edumazet@google.com>
Subject: Re: net/llc: BUG in llc_sap_state_process/skb_set_owner_r
Date: Sun, 12 Feb 2017 09:10:48 -0800
Message-ID: <CANn89iKww-oSWGWx-PZ_gXYmeFr8NSwJS55vNB=jyaBghTmtvA@mail.gmail.com>
References: <CAAeHK+yzH_M4uzetrMQPMgYBNDXYAp0V11DcMtUgNWVvPg4x=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: acme@redhat.com, "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+yzH_M4uzetrMQPMgYBNDXYAp0V11DcMtUgNWVvPg4x=g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 12, 2017 at 8:44 AM, Andrey Konovalov <andreyknvl@google.com> wrote:
> Hi,
>
> I've got the following error report while fuzzing the kernel with syzkaller.
>
> On commit 926af6273fc683cd98cd0ce7bf0d04a02eed6742.
>
> A reproducer and .config are attached

Thanks for the report.

llc sets skb->sk   without corresponding skb->destructor.

This is considered invalid by our current standards.

As I added the sanity check in skb_destructor() back in linux-3.12
(!!!), I will send the corresponding LLC fix.

( commit 376c7311bdb6efea3322310333576a04d73fbe4c )
