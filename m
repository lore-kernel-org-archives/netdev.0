From: Johan Hovold <jhovold-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: bluetooth: bug fixes for bluetooth-next
Date: Thu, 15 Mar 2012 14:47:35 +0100
Message-ID: <20120315134735.GA19821@localhost>
References: <1331307806-21761-1-git-send-email-jhovold@gmail.com>
 <20120314112543.GA5136@localhost>
 <1331749014.14217.112.camel@aeonflux>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Herrmann <dh.herrmann-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	Greg KH <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Johan Hovold <jhovold-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	"Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1331749014.14217.112.camel@aeonflux>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 14, 2012 at 11:16:54AM -0700, Marcel Holtmann wrote:
> > > This is a revised series which also contains a minimal fix to the memory leak
> > > discovered by David Hermann upon which the first NULL-pointer-dereference fix
> > > also depends.
> > > 
> > > These patches need to get to Linus ASAP as the problems are present in 3.3-rc6
> > > as well as earlier kernels and thus should be backported to the stable trees as
> > > well.
> > 
> > Any chance to get these into 3.3? Otherwise, is it possible to rebase
> > bluetooth-next on top of these so that Greg can get them into 3.3.1 (and
> > the other stable trees) once bluetooth-next is merged?
> > 
> > All three bugs can be used to crash any kernel with HCI-UART support and
> > can probably be used for exploits as they are extremely easy to trigger
> > reliably.
> 
> only if you have access to the TTY device node in the first place. If
> you do not have access to that device node, you can not crash the
> kernel.
> 
> Can you resend a clean set of patches for bluetooth-next and once we
> have that merged, we can talk on how to backport this to 3.3 and also
> -stable.

I'll respond to this mail with the two NULL-deref fixes against
bluetooth-next of today (44e612b3e6566f0b).

As I've mentioned before, a fix for the memory leak is already in
bluetooth-next and my first patch depends on it. Unfortunately, the
memory-leak fix in bluetooth-next is not a minimal fix but a more
invasive one:

	797fe796c4335b3 ("Bluetooth: uart-ldisc: Fix memory leak and
			  remove destruct cb")
	
and it also depends on a second commit (from bluetooth-next):

	010666a126fce7b ("Bluetooth: Make hci-destruct callback
			  optional")

Neither is marked for stable (and at least the latter probably shouldn't
be).

Please make sure that the memory leak fix also gets backported to
stable. A minimal (2-line) fix can be found here:

	http://marc.info/?l=linux-bluetooth&m=133130797428708&w=2

Thanks,
Johan
