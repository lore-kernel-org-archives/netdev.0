From: Julius Werner <jwerner@chromium.org>
Subject: Re: [PATCH] tcp: Replace infinite loop on recvmsg bug with proper crash
Date: Tue, 6 Nov 2012 17:51:19 -0800
Message-ID: <CAODwPW-636Sn3B4CYajvrgccXxresZwPLg2UFz6xDDk9-FfTYQ@mail.gmail.com>
References: <1352247335-10396-1-git-send-email-jwerner@chromium.org>
	<20121107013907.GA31185@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Dave Jones <davej@redhat.com>,
	Julius Werner <jwerner@chromium.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Sameer Nanda <snanda@chromium.org>,
	Mandeep Singh Baines <msb@chromium.org>,
	Eric Dumazet <edumazet@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121107013907.GA31185@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> We've had reports of this WARN against the Fedora kernel for a while.
> Had this been immediately followed by a BUG(), we'd have never seen those traces at all,
> and just got "my machine just locked up" reports instead.
>
> The proper fix here is to find out why we're getting into this state.

Are you sure you don't mean the WARN below that ("recvmsg bug 2")
instead? I don't think this one can happen without eventually running
into the syslog overflow issue I described.

I agree that the underlying cause must be fixed too, but as we will
always have bugs in the kernel I think proper handling when it does
happen is also important (and filling the hard disk with junk is
obviously not the best approach). If you think a full panic is too
extreme, I have an alternative version of this patch that logs the
WARN once, closes the socket, and returns EBADFD from the syscall...
would you think that is more appropriate?
