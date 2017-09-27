From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] netlink: do not proceed if dump's start() errs
Date: Wed, 27 Sep 2017 15:05:14 +0200
Message-ID: <1506517514.2108.2.camel@sipsolutions.net>
References: <20170927123915.5779-1-Jason@zx2c4.com>
         <CAHmME9pUWenvkMCNkAHa6K71UDdETvriMr52sKPL38q19M3RVw@mail.gmail.com>
         (sfid-20170927_145125_802166_2DBE683F)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: stable@vger.kernel.org
To: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9pUWenvkMCNkAHa6K71UDdETvriMr52sKPL38q19M3RVw@mail.gmail.com> (sfid-20170927_145125_802166_2DBE683F)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-09-27 at 14:50 +0200, Jason A. Donenfeld wrote:
> On Wed, Sep 27, 2017 at 2:39 PM, Jason A. Donenfeld <Jason@zx2c4.com>
> wrote:
> > -       if (cb->start)
> > -               cb->start(cb);
> > +       if (cb->start) {
> > +               ret = cb->start(cb);
> > +               if (ret)
> 
> I need to sock_put(sk); before returning. I'll fix this for v2, but
> will for additional comments in case anybody has some.

I guess you could change it to

if (cb->start)
	ret = cb->start(cb);
if (!ret)
	ret = netlink_dump(sk);

johannes
