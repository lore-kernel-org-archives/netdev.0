From: Kees Cook <keescook@chromium.org>
Subject: Re: user controllable usermodehelper in br_stp_if.c
Date: Mon, 30 Nov 2015 12:14:41 -0800
Message-ID: <CAGXu5jJqQKAmFK0nL69E0QOpo8WSVDqStGZo7-m7gy3vnXBa=A@mail.gmail.com>
References: <565B7F7D.80208@nod.at>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, bridge@lists.linux-foundation.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Richard Weinberger <richard@nod.at>, "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <kernel-hardening-return-2018-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
Sender: keescook@google.com
In-Reply-To: <565B7F7D.80208@nod.at>
List-Id: netdev.vger.kernel.org

On Sun, Nov 29, 2015 at 2:43 PM, Richard Weinberger <richard@nod.at> wrote:
> Hi!
>
> By spawning new network and user namesapces an unprivileged user
> is able to execute /sbin/bridge-stp within the initial mount namespace
> with global root rights.
> While this cannot directly be used to break out of a container or gain
> global root rights it could be used by exploit writers as valuable building block.
>
> e.g.
> $ unshare -U -r -n /bin/sh
> $ brctl addbr br0
> $ brctl stp br0 on # this will execute /sbin/bridge-stp
>
> As this mechanism clearly cannot work with containers and seems to be legacy code
> I suggest not calling call_usermodehelper() at all if we're not in the initial user namespace.
> What do you think?

I'm not familiar with how bridge-stp is expected to operate with a
network namespace, but if it's meaningless, then yeah, that seems like
a reasonable change. Can you send a patch? (Also, if it's legacy code,
maybe it could be turned off entirely, not just for containers?)

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security
