From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Replace infinite loop on recvmsg bug with proper
 crashusers
Date: Wed, 07 Nov 2012 09:05:02 -0800
Message-ID: <1352307902.3140.4588.camel@edumazet-glaptop>
References: <1352247335-10396-1-git-send-email-jwerner@chromium.org>
	 <20121107013907.GA31185@redhat.com>
	 <CAODwPW-636Sn3B4CYajvrgccXxresZwPLg2UFz6xDDk9-FfTYQ@mail.gmail.com>
	 <20121107155434.GA17677@redhat.com>
	 <1352305752.3140.4449.camel@edumazet-glaptop>
	 <20121107164358.GA20495@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Julius Werner <jwerner@chromium.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Sameer Nanda <snanda@chromium.org>,
	Mandeep Singh Baines <msb@chromium.org>,
	Eric Dumazet <edumazet@chromium.org>
To: Dave Jones <davej@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121107164358.GA20495@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-11-07 at 11:43 -0500, Dave Jones wrote:

> dude, look at the bug reports I just pointed you at.
> People _are_ aware there are bugs there.
> 

If I remember well, I helped to fix some of them.

> If you turn that into a BUG() those reports would never have been filed.
> How is that increasing awareness ?  People are going to see wedged computers,
> and hit the reset button. If we're lucky, we'll get photos of someone lucky
> enough to have hit it while at the console, not in X. But this is a huge
> step backwards for debugability.
> 
>  > I understand a distro maintainer has its own choices, but for upstream
>  > kernel we want to have early reports.
> 
> I'm running out of ways to word this, but I'll try again.
> You won't get those early reports if you turn this into a BUG().
> 
>  > This bug is fatal and a security issue. BUG() is appropriate.
> 
> turning a bug into a remote DoS is also a security issue.
> 

Apparently in some cases we can loop and fill the syslog, or
else Julius wouldnt have sent a patch.

So the proper fix is to emit this message only once, and to find
a way to alert the user security is compromised.

So if BUG() isnt good, just use WARN_ON_ONCE()

I feel that WARN_ON_ONCE() wont be clear enough to the user, especially
if we recover from this by closing the tcp session, exactly as if we
received a proper FIN.

Really if you object a BUG() here, I cant understand you didnt shout to
other BUG() uses in the kernel.
