From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: net/icmp: null-ptr-deref in icmp6_send
Date: Tue, 22 Nov 2016 22:10:37 -0500
Message-ID: <65c99b22-9336-ebfe-064b-8a2b3ee3c8dd@cumulusnetworks.com>
References: <CAAeHK+wRE7y_0d7djWnq9S1O_w-1wQRq1g7VsAmzEAE+JY_v2Q@mail.gmail.com>
 <CAM_iQpUQtt2CGrYF4H2DJv_NRsmnBqkXj5rJVXD8osJBFz_qYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Alexander Potapenko <glider@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>,
        Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpUQtt2CGrYF4H2DJv_NRsmnBqkXj5rJVXD8osJBFz_qYw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/22/16 1:11 PM, Cong Wang wrote:
> I have no idea what commit 5d41ce29e tried to fix, but we already
> use skb->dev a few lines before l3mdev_master_ifindex(), so I don't
> understand why skb->dev could be NULL, maybe just for vrf dev?

skb->dev can be null depending on when icmp6_send / icmpv6_send is called. Clearly I missed the ipv6_parse_hopopts -> icmpv6_param_prob path. I'll send a fix when I get back from PTO.
