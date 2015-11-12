From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Is ndo_do_ioctl still acceptable?
Date: Thu, 12 Nov 2015 14:27:17 -0800
Message-ID: <20151112142717.7144e931@xeon-e3>
References: <CAHmME9puHv8uaUKX4AOjEaTNN6bHqNKqvaCqubc5erk+jnDOEw@mail.gmail.com>
	<20151112083443.48785696@xeon-e3>
	<CAHmME9p31NYxhUeiK=S-6XmKxEBigUyiqEz3SJJrA1zNXaaXLA@mail.gmail.com>
	<5644F6E7.4060901@gmail.com>
	<CAHmME9pHg7iAorj22DvWKhrH4HXPne7ZBAr7X1wyR7VEkJfk8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Austin S Hemmelgarn <ahferroin7@gmail.com>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9pHg7iAorj22DvWKhrH4HXPne7ZBAr7X1wyR7VEkJfk8w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Nov 2015 23:19:06 +0100
"Jason A. Donenfeld" <Jason@zx2c4.com> wrote:

> On Thu, Nov 12, 2015 at 9:30 PM, Austin S Hemmelgarn
> <ahferroin7@gmail.com> wrote:
> >>
> > On the other hand, based on what you are saying about your device, it sounds
> > like you are working on some kind of cryptographically secured (either
> > authenticated or encrypted or both) tunnel, in which case the fact that
> > security is easier to handle with netlink than ioctls becomes important.  If
> > you can't ensure security of the endpoint configuration, you can't ensure
> > security of the tunnel itself.
> 
> Could you substantiate these claims that "security is easier to handle
> with netlink". I've never heard this and I don't know why it'd be the
> case. Are you referring to the fact that the copy_to/from_user dance
> of ioctl opens up more potential vulnerabilities than netlink's
> abstracted validation? Or something else? Just confused here...

It means that with netlink it possible to checks on field types and lengths
in generic manner. Ioctl's have the whole compat mess to deal with.
Also when using seccomp it is possible to write code to look at netlink
messages. With ioctl's that is much more difficult especially since the
same ioctl may have different meanings for each device type.
