From: Roland Dreier <roland@topspin.com>
Subject: Re: [PATCH][RFC/v1][8/12] Add IPoIB
	(IP-over-InfiniBand) driver
Date: Mon, 22 Nov 2004 15:18:07 -0800
Message-ID: <52k6sdbhhs.fsf@topspin.com>
References: <20041122713.FnSlYodJYum7s82D@topspin.com>
	<20041122714.nKCPmH9LMhT0X7WE@topspin.com>
	<20041122223432.GC15634@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	openib-general@openib.org
Return-path: <openib-general-bounces@openib.org>
To: Greg KH <greg@kroah.com>
In-Reply-To: <20041122223432.GC15634@kroah.com> (Greg KH's message of "Mon,
	22 Nov 2004 14:34:32 -0800")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

    Greg> What's wrong with using the dev_printk() and friends instead
    Greg> of your own?

dev_printk expects a struct device, not a net_device.

    Greg> And why cast a pointer in a macro, don't you know the type
    Greg> of it anyway?

this lets us pass in the return value of netdev_priv() directly
without having to have the cast in the code that uses the macro.

    Greg> You're using a separate filesystem to export debug data?
    Greg> I'm all for new virtual filesystems, but why not just use
    Greg> sysfs for this?  What are you doing in here that you can't
    Greg> do with another mechanism (netlink, sysfs, sockets, relayfs,
    Greg> etc.)?

For each multicast group, we want to export the GID, how long it's
been around, whether our join has completed and whether it's
send-only.  It wouldn't be too bad to create a kobject with all those
attributes but getting the info from so many little files is a little
bit of a pain, and so is dealing with kobject lifetime rules.  It's
even worse with netlink since then a new tool is required.  (AFAIK
relayfs isn't in Linus's kernel).

It's nice to be able to tell someone to just mount ipoib_debugfs and
send the contents of debugfs/ib0_mcg.

The actual filesystem stuff is pretty trivial using everything libfs
provides for us now...

    Greg> Why not just use 2 different debug variables for this?

No real reason... I'll fix it up.

    >> + +int mcast_debug_level;

    Greg> Global?

Good point, I'll move it into ipoib_multicast.c.

 - R.
