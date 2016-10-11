From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: slab corruption with current -git
Date: Mon, 10 Oct 2016 17:54:08 -0700
Message-ID: <CA+55aFxsy7eJrP3uQK4URHu=Rk9Z75TGP5TOT1L_bAY4jgoJKQ@mail.gmail.com>
References: <f7ta8ec71qq.fsf@redhat.com> <CA+55aFy6pRhvodYG9WWjfxQBFr4ExSk_wxwY=treWYTPK+NTvQ@mail.gmail.com>
 <CA+55aFy0szySf+SnysjXTyfiU=RMBo9U1sHAVaTKG=tUTF+XGw@mail.gmail.com> <20161010.203019.388602181022157591.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Aaron Conole <aconole@redhat.com>, Florian Westphal <fw@strlen.de>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Jens Axboe <axboe@fb.com>, "Theodore Ts'o" <tytso@mit.edu>,
        Christoph Lameter <cl@linux.com>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        NetFilter <netfilter-devel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161010.203019.388602181022157591.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 10, 2016 at 5:30 PM, David Miller <davem@davemloft.net> wrote:
>
> Linus can you add some extra info to that:

Sure. I made it a WARN_ON_ONCE(), but then always just printed the
pf/hooknum. It's all over the map:

 reg->pf=2 and reg->hooknum=4
 reg->pf=2 and reg->hooknum=2
 reg->pf=2 and reg->hooknum=3
 reg->pf=10 and reg->hooknum=4
 reg->pf=10 and reg->hooknum=2
 reg->pf=10 and reg->hooknum=3
 reg->pf=7 and reg->hooknum=1
 reg->pf=7 and reg->hooknum=2
 reg->pf=7 and reg->hooknum=3
 reg->pf=2 and reg->hooknum=0
 reg->pf=2 and reg->hooknum=3
 reg->pf=2 and reg->hooknum=0
 reg->pf=2 and reg->hooknum=3
 reg->pf=2 and reg->hooknum=4
 reg->pf=2 and reg->hooknum=4
 reg->pf=2 and reg->hooknum=1
 reg->pf=2 and reg->hooknum=1
 reg->pf=10 and reg->hooknum=0
 reg->pf=10 and reg->hooknum=3
 reg->pf=10 and reg->hooknum=0
 reg->pf=10 and reg->hooknum=3
 reg->pf=10 and reg->hooknum=4
 reg->pf=10 and reg->hooknum=4
 reg->pf=10 and reg->hooknum=1
 reg->pf=10 and reg->hooknum=1
 reg->pf=7 and reg->hooknum=3
 reg->pf=7 and reg->hooknum=4
 reg->pf=7 and reg->hooknum=0
 reg->pf=2 and reg->hooknum=4
 reg->pf=2 and reg->hooknum=2
 reg->pf=2 and reg->hooknum=3
 reg->pf=10 and reg->hooknum=4
 reg->pf=10 and reg->hooknum=2
 reg->pf=10 and reg->hooknum=3
 reg->pf=7 and reg->hooknum=1
 reg->pf=7 and reg->hooknum=2
 reg->pf=7 and reg->hooknum=3
 reg->pf=2 and reg->hooknum=0
 reg->pf=2 and reg->hooknum=3
 reg->pf=2 and reg->hooknum=0
 reg->pf=2 and reg->hooknum=3
 reg->pf=2 and reg->hooknum=4
 reg->pf=2 and reg->hooknum=4
 reg->pf=2 and reg->hooknum=1
 reg->pf=2 and reg->hooknum=1
 reg->pf=10 and reg->hooknum=0
 reg->pf=10 and reg->hooknum=3
 reg->pf=10 and reg->hooknum=0
 reg->pf=10 and reg->hooknum=3
 reg->pf=10 and reg->hooknum=4
 reg->pf=10 and reg->hooknum=4
 reg->pf=10 and reg->hooknum=1
 reg->pf=10 and reg->hooknum=1
 reg->pf=7 and reg->hooknum=3
 reg->pf=7 and reg->hooknum=4
 reg->pf=7 and reg->hooknum=0

and putting that through "sort -n" and "uniq -c", I get:

      4  reg->pf=10 and reg->hooknum=0
      4  reg->pf=10 and reg->hooknum=1
      2  reg->pf=10 and reg->hooknum=2
      6  reg->pf=10 and reg->hooknum=3
      6  reg->pf=10 and reg->hooknum=4
      4  reg->pf=2 and reg->hooknum=0
      4  reg->pf=2 and reg->hooknum=1
      2  reg->pf=2 and reg->hooknum=2
      6  reg->pf=2 and reg->hooknum=3
      6  reg->pf=2 and reg->hooknum=4
      2  reg->pf=7 and reg->hooknum=0
      2  reg->pf=7 and reg->hooknum=1
      2  reg->pf=7 and reg->hooknum=2
      4  reg->pf=7 and reg->hooknum=3

which doesn't look much better. But clearly there's a lot of those
"try to unregister stuff that you can't even find".

Maybe it tells you something.

               Linus
