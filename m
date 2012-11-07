From: Julius Werner <jwerner@chromium.org>
Subject: Re: [PATCH] tcp: Avoid infinite loop on recvmsg bug
Date: Wed, 7 Nov 2012 13:14:58 -0800
Message-ID: <CAODwPW8mBJspF3k5SCBR-BShNvBLQpD-vyhLRh5Cq-4h=VZDgg@mail.gmail.com>
References: <CAODwPW9kiG-jo=n0zedv5KT-8-gJcEUrdC3F2mAEjt78tne18g@mail.gmail.com>
	<1352316791-16491-1-git-send-email-jwerner@chromium.org>
	<1352317219.5552.6.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Dave Jones <davej@redhat.com>,
	Sameer Nanda <snanda@chromium.org>,
	Mandeep Singh Baines <msb@chromium.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352317219.5552.6.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> What I find very sad in all this is that you didnt mention the driver
> that was triggering this bug.

Sorry, I was just trying to keep this thread focussed on one patch.
The bug report that led me to this is publicly accessible at
http://crosbug.com/35827. We have encountered the problem only once,
on an Acer AC700 Chromebook that ran automated tests. The ethernet
interface for the offending socket was provided by a USB-to-Ethernet
dongle using the smsc95xx/usbnet module (v1.0.4).

Don't get me wrong, I do understand the importance of finding the
underlying cause of this... I just don't think I have much of a chance
with one report. I can go through the above-mentioned module and see
if something looks suspicious in the skb handling code if I can find
the time. But on the other hand the fact remains that this condition
is not handled well... not just for this particular case, but for all
future kernel and driver bugs that may trigger it again. I am not
trying to "hide" any issues, I am all for making them as visible as
possible... but as Dave pointed out, kernel panics may not be the best
way to do that either, and I think damage mitigation also has some
value. The current code clearly does the worst of both worlds, so
please let's just improve it one way or the other.
