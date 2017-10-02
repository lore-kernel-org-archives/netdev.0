From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: v4.14-rc2/arm64 kernel BUG at net/core/skbuff.c:2626
Date: Mon, 2 Oct 2017 18:34:02 +0100
Message-ID: <20171002173401.GA3456@leverpostej>
References: <20171002104947.GE20737@leverpostej>
 <CANn89i++X2rzsaHkTRayMpCED_exL8WPq12=RwD_hXsZ6cN-wQ@mail.gmail.com>
 <20171002142156.GB21696@leverpostej>
 <1506955708.8061.5.camel@edumazet-glaptop3.roam.corp.google.com>
 <20171002172131.GA3360@leverpostej>
 <CANn89iKXGx2AmaYtqaD_CTvxgG2xC6vbuuNigixtUM82fExODQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        linux-arm-kernel@lists.infradead.org,
        syzkaller <syzkaller@googlegroups.com>,
        "David S. Miller" <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CANn89iKXGx2AmaYtqaD_CTvxgG2xC6vbuuNigixtUM82fExODQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 02, 2017 at 10:27:15AM -0700, Eric Dumazet wrote:
> On Mon, Oct 2, 2017 at 10:21 AM, Mark Rutland <mark.rutland@arm.com> wrote:
> > On Mon, Oct 02, 2017 at 07:48:28AM -0700, Eric Dumazet wrote:
> >> Please try the following fool proof patch.
> >>
> >> This is what I had in my local tree back in August but could not
> >> conclude on the syzkaller bug I was working on.
> >>
> >> diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
> >> index 681e33998e03b609fdca83a83e0fc62a3fee8c39..e51d777797a927058760a1ab7af00579f7488cb5 100644
> >> --- a/net/ipv4/icmp.c
> >> +++ b/net/ipv4/icmp.c
> >> @@ -732,7 +732,8 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
> >>               room = 576;
> >>       room -= sizeof(struct iphdr) + icmp_param.replyopts.opt.opt.optlen;
> >>       room -= sizeof(struct icmphdr);
> >> -
> >> +     if (room < 0)
> >> +             goto ende;
> >>       icmp_param.data_len = skb_in->len - icmp_param.offset;
> >>       if (icmp_param.data_len > room)
> >>               icmp_param.data_len = room;
> >>
> >
> > Unfortuantely, with this applied I still see the issue.
> >
> > Syzkaller came up with a minimized reproducer [1], which can trigger the
> > issue near instantly under syz-execprog. If there's anything that would
> > help to narrow this down, I'm more than happy to give it a go.
> >
> > Thanks,
> > Mark.
> >
> > [1] https://www.kernel.org/pub/linux/kernel/people/mark/bugs/20171002-skb_clone-misaligned-atomic/syzkaller.repro
> 
> Note that I was not trying to address the misaligned stuff.

Aargh, I put the reproducer in the wrong folder thanks to tab-completing
my kup command. :/

The reproducer linked above is for the kernel BUG at
net/core/skbuff.c:2626.

I've uploaded a copy into the relevant bug directory [1], but that'll
take a little while to sync out. I'll drop it from the misalignment bug
folder once that's visible to all.

Sorry about that!

Thanks,
Mark.

[1] https://www.kernel.org/pub/linux/kernel/people/mark/bugs/20171002-skbuff-bug/
