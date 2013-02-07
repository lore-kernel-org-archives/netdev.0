From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH] tcp: sysctl to disable TCP simultaneous connect
Date: Thu, 7 Feb 2013 10:44:02 -0800
Message-ID: <CAGXu5jJiupzommJYPEYQnk-4i9FUKai0NcPnihLN-QpWV64jtQ@mail.gmail.com>
References: <20130207175240.GA12520@www.outflux.net>
	<20130207103950.662698ea@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: LKML <linux-kernel@vger.kernel.org>, Rob Landley <rob@landley.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Eric Dumazet <edumazet@google.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Yuchung Cheng <ycheng@google.com>,
	Shan Wei <davidshan@tencent.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	netdev@vger.kernel.org, Willy Tarreau <w@1wt.eu>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20130207103950.662698ea@nehalam.linuxnetplumber.net>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 7, 2013 at 10:39 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Thu, 7 Feb 2013 09:52:40 -0800
> Kees Cook <keescook@chromium.org> wrote:
>
>> This is based on Willy Tarreau's patch from 2008[1]. The goal is to
>> close a corner-case of TCP that isn't used and poses a small DoS risk.
>> For systems that do not want to take any risk at all, this is a desirable
>> configuration knob.
>>
>> It is possible for two clients to connect with crossed SYNs without
>> checking sequence numbers. As such, it might be possible to guess a source
>> port number to block a system from making connections to well-known
>> ports and IP addresses (e.g. auto-update checks) without requiring a
>> MiTM position.
>>
>
> This patch probably also breaks TCP STUNT that is used by some applications for NAT
> traversal.

The patch would not break it -- it defaults the sysctl to staying enabled.

If you mean the documentation should be updated, sure, that's easy to do.

David: I know you aren't a fan of this patch, but I'd like to try to
convince you. :) This leaves the feature enabled and add a toggle for
systems (like Chrome OS) that don't want to risk this DoS at all.
There are so very many other toggle, I don't see why this one would be
a problem to add.

-Kees

--
Kees Cook
Chrome OS Security
