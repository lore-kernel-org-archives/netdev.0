From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: net/rds: use-after-free in inet_create
Date: Tue, 28 Feb 2017 11:38:33 -0500
Message-ID: <20170228163833.GI31155@oracle.com>
References: <CACT4Y+bi=rZr9yrajA0o0iUeR4N0q-sXYudBVsOeOiHbuApBeA@mail.gmail.com>
 <20170228153737.GG31155@oracle.com>
 <CACT4Y+aobp+g_AYoX6j1eftyyirK4pBxhOXz9hDu+XU+-jxSYw@mail.gmail.com>
 <20170228161544.GH31155@oracle.com>
 <CACT4Y+bWWAiMYQN_Fvxs7CKR9hRAA+r0t_YZhja3B5xGcZ4vcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: santosh.shilimkar@oracle.com, David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com, LKML <linux-kernel@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACT4Y+bWWAiMYQN_Fvxs7CKR9hRAA+r0t_YZhja3B5xGcZ4vcQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On (02/28/17 17:32), Dmitry Vyukov wrote:
> Not reproducible so far.
> 
> rds is compiled into kernel (no modules):
> CONFIG_RDS=y
> CONFIG_RDS_TCP=y

I see. So if it never gets unloaded, the rds_connections "should"
be around forever.. let me inspect code and see if I spot some 
race-window.. 

> Also fuzzer actively creates and destroys namespaces.
> Yes, I don't see socket(0x15) in the log. Probably it was truncated.

I see. May be useful if we coudl get a crash dump to see what
other threads were going on (might give a hint about which threads
were racing). I'll try reproducing this at my end too.

--Sowmini
