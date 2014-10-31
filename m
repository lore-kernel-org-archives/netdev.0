From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: avoid divide 0 error in tcp_incr_quickack
Date: Fri, 31 Oct 2014 10:40:42 -0700
Message-ID: <1414777242.27538.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414767047-8972-1-git-send-email-chenweilong@huawei.com>
	 <CAADnVQLe+Xs22sbdy7=8KW2+LscFOiFWdKxSFFuPTWSPTHbSow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Chen Weilong <chenweilong@huawei.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAADnVQLe+Xs22sbdy7=8KW2+LscFOiFWdKxSFFuPTWSPTHbSow@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-10-31 at 09:24 -0700, Alexei Starovoitov wrote:
> cc-ing netdev
> 
> On Fri, Oct 31, 2014 at 7:50 AM, Chen Weilong <chenweilong@huawei.com> wrote:
> > From: Weilong Chen <chenweilong@huawei.com>
> >
> > We got a problem like this:
> >  [ffff8801c1a05570] machine_kexec at ffffffff81025039
> >  [ffff8801c1a055d0] crash_kexec at ffffffff8109b253
> >  [ffff8801c1a056a0] oops_end at ffffffff81442aed
> >  [ffff8801c1a056d0] die at ffffffff81005603
> >  [ffff8801c1a05700] do_trap at ffffffff81442448
> >  [ffff8801c1a05760] do_divide_error at ffffffff81002c10
> >  [ffff8801c1a05888] tcp_send_dupack at ffffffff81385e44
> >  [ffff8801c1a058c8] tcp_validate_incoming at ffffffff813886b5
> >  [ffff8801c1a05908] tcp_rcv_state_process at ffffffff8138d0b7
> >  [ffff8801c1a05958] tcp_child_process at ffffffff81397255
> >  [ffff8801c1a05988] tcp_v4_do_rcv at ffffffff81395a70
> >  [ffff8801c1a059d8] tcp_v4_rcv at ffffffff81396fc8
> >  [ffff8801c1a05a48] ip_local_deliver_finish at ffffffff813746e9
> >  [ffff8801c1a05a78] ip_local_deliver at ffffffff81374a20
> >  [ffff8801c1a05aa8] ip_rcv_finish at ffffffff81374389
> >  [ffff8801c1a05ad8] ip_rcv at ffffffff81374c78
> > There was a wrong ack packet coming during TCP handshake. The socket's state
> > was TCP_SYN_RECV, its rcv_mss was not initialize yet. So
> > tcp_send_dupack -> tcp_enter_quickack_mode got a divide 0 error.
> > This patch add a state check before tcp_enter_quickack_mode.
> 
> ouch. Is it remote exploitable?

Seems to be SYN crossing. Quite hard, but possible.
