From: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: idr_get_new_exact ?
Date: Mon, 20 Sep 2010 13:35:42 -0700
Message-ID: <adaiq20f90h.fsf@cisco.com>
References: <AANLkTi=ZLupVyFR0e2v-TLpeNWdw1bVMZUAhgyxLJ7OV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Jean Delvare \(PC drivers\, core\)" <khali-PUYAD+kWke1g9hUCZPvPmw@public.gmane.org>,
	"Ben Dooks \(embedded platforms\)" <ben-linux-elnMNo+KYs3YtjvyW6yDsg@public.gmane.org>,
	Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Steve Wise <swise-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, Neil Brown <neilb-l3A5Bk7waGM@public.gmane.org>,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>, linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	linux-raid-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ppp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
To: Ohad Ben-Cohen <ohad-Ix1uc/W3ht7QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AANLkTi=ZLupVyFR0e2v-TLpeNWdw1bVMZUAhgyxLJ7OV-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Ohad Ben-Cohen's message of "Mon, 20 Sep 2010 16:11:31 +0200")
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 > Occasionally, drivers care about the value that idr associates with
 > their pointers.
 > 
 > Today we have idr_get_new_above() which allocates a new idr entry
 > above or equal to a given starting id, but sometimes drivers need to
 > force an exact value.
 > 
 > To overcome this small API gap, drivers are wrapping idr_get_new_above
 > and then either BUG_ON() or just call idr_remove() and returns -EBUSY
 > when idr allocates them an id which is different than their requested
 > value.

Looks fine to me as an improvement over the status quo, but I wonder how
many of these places could use the radix_tree stuff instead?  If you're
not using the ability of the idr code to assign an id for you, then it
seems the radix_tree API is a better fit.

 - R.
