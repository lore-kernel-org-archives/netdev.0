From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: IPv4/IPv6 sysctl defaults in new namespace
Date: Mon, 15 Feb 2016 15:26:07 -0600
Message-ID: <87k2m57jio.fsf@x220.int.ebiederm.org>
References: <CALYGNiNJ=LCyo4v7B1BUZH-27bc22ap-RQKpPQN7m0V3kBjkPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Vasily Averin <vvs-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Pavel Emelyanov <xemul-5HdwGun5lf+gSpxsJD1C4w@public.gmane.org>
To: Konstantin Khlebnikov <koct9i-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CALYGNiNJ=LCyo4v7B1BUZH-27bc22ap-RQKpPQN7m0V3kBjkPw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Konstantin Khlebnikov's message of "Mon, 15 Feb 2016 13:49:18 +0300")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Konstantin Khlebnikov <koct9i-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> IPv6 initialized with default. That's ok.
> IPv4 makes a copy from init_net. Looks like a bug, here
> v2.6.24-2577-g752d14dc6aa9
>
> root@zurg:~# sysctl net.ipv4.conf.all.forwarding=0
> net.ipv6.conf.all.forwarding=0
> net.ipv4.conf.all.forwarding = 0
> net.ipv6.conf.all.forwarding = 0
> root@zurg:~# unshare -n sysctl net.ipv4.conf.all.forwarding
> net.ipv6.conf.all.forwarding
> net.ipv4.conf.all.forwarding = 0
> net.ipv6.conf.all.forwarding = 0
> root@zurg:~# sysctl net.ipv4.conf.all.forwarding=1
> net.ipv6.conf.all.forwarding=1
> net.ipv4.conf.all.forwarding = 1
> net.ipv6.conf.all.forwarding = 1
> root@zurg:~# unshare -n sysctl net.ipv4.conf.all.forwarding
> net.ipv6.conf.all.forwarding
> net.ipv4.conf.all.forwarding = 1
> net.ipv6.conf.all.forwarding = 0
>
> This is nasty. Could we fix this or this bug set in stone?

The test is do we break anyone, and the initial network namespace
is arbitrary enough I don't think anyone can depend upon a specific
value when creating a new network namespace.  So if someone is willing
to do the work we can fix this.

Of course the fixes would have to made against a recent kernel not
something as ancient as 2.6.24.

Eric
