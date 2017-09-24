From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RESEND] Re: usb/net/p54: trying to register non-static key in
 p54_unregister_leds
Date: Sun, 24 Sep 2017 16:13:38 +0200
Message-ID: <1506262418.2909.1.camel@sipsolutions.net>
References: <CAAeHK+xPoNn7i5xOzEqHX6tfDpmpb1rd0hcAxZpTHKi6B8xzsw@mail.gmail.com>
         <1505937307.3026.20.camel@sipsolutions.net>
         <CAAeHK+wWRZuCDNhoZJ0ACDhiNQw8tVRp2HW0j1EDH0HOe523xA@mail.gmail.com>
         <2589427.Vd4nrgaY4N@debian64> (sfid-20170923_213736_879752_15E98466)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>,
        Stephen Boyd <sboyd@codeaurora.org>, Tejun Heo <tj@kernel.org>,
        Yong Zhang <yong.zhang0@gmail.com>
To: Christian Lamparter <chunkeey@googlemail.com>,
        Andrey Konovalov <andreyknvl@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2589427.Vd4nrgaY4N@debian64> (sfid-20170923_213736_879752_15E98466)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2017-09-23 at 21:37 +0200, Christian Lamparter wrote:

> But this also begs the question: Is this really working then?
> From what I can tell, if CONFIG_LOCKDEP is not set then there's no
> BUG no WARN, no other splat or any other odd system behaviour. Does
> [cancel | flush]_[delayed_]work[_sync] really "just work" by
> *accident*, as long the delayed_work | work_struct is zeroed out? 

It looks like it does, but I'm not sure it's not more or less by
accident. Look at get_work_pool() for example, it might actually return
non-NULL in this case, and then in start_flush_work() you'll probably
fall into one of the few "already_gone" cases.

> And should it work in the future as well?

I guess it's not really guaranteed, the API doesn't state anything to
that effect. Not that I'm looking forward to a new workqueue rewrite ;)

johannes
