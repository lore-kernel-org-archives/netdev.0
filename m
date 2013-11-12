From: Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>
Subject: Re: [PATCH net-next 3/6] random32: add prandom_reseed_late() and call when nonblocking pool becomes initialized
Date: Tue, 12 Nov 2013 14:16:27 +0100
Message-ID: <20131112131627.GD14929@order.stressinduktion.org>
References: <cover.1384160397.git.dborkman@redhat.com> <2ea03f60bb65429cbe5d74a6d356fde3eefcf06c.1384160397.git.dborkman@redhat.com> <20131111134357.GC10104@thunk.org> <20131112000307.GB14929@order.stressinduktion.org> <20131112115350.GA14077@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	shemminger-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, fweimer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20131112115350.GA14077-AKGzg7BKzIDYtjvyW6yDsg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 12, 2013 at 06:53:50AM -0500, Theodore Ts'o wrote:
> > Btw. do you see problems regarding get_random_int on architectures without
> > hardware offloading?
> > 
> > We are initializing random_int_secret really late (after all the init
> > calls) and I wonder if we should also use a two stage initialization
> > there, so we have a more unpredictable MD5 hash at early boot.
> 
> Most of the users of get_random_int(), at least to date, have been for
> things like ASLR.  A quick audit shows only one device driver user
> that might be impacted: drivers/net/wireless/cw1200/wsm.c.
> 
> It's not a bad idea to do a two stage init just in case
> get_random_int() gets used by other code --- although that brings up
> something that I know is really needed, but which I haven't had time
> to try to address yet: we really need to document all of the various
> interfaces that various kernel routines can use to get random numbers,
> and document what their performance and security characteristics are.
> We have probably have a lot of code where the authors didn't realize
> that some other interface would be a better match for their needs, or
> the code is old enough that predates some of the newer interfaces.

It is needed by fork to set up the stack canary. And this actually gets
called before the secret is initialized.

Btw. the kaslr seeding techniques become quite interesting. It looks like
they want to hash struct boot_params, maybe the ACPI memory part and also the
DMI table.

I guess we should start to implement an interface for early-boot entropy which
the architectures must override to not use jiffies ^ get_cycles() all the
time.

The documentation idea also does sound as a very good one. ;)

Greetings,

  Hannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
