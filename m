From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]  e100: Enable receiving bogus packets, and transmitting
 bad/custom CRC
Date: Mon, 24 Nov 2003 17:33:30 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031124173330.096c0751.davem@redhat.com>
References: <3FC2931B.3070903@candelatech.com>
	<20031124152933.1420f6cf.davem@redhat.com>
	<3FC298C9.8080302@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, scott.feldman@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3FC298C9.8080302@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 24 Nov 2003 15:48:25 -0800
Ben Greear <greearb@candelatech.com> wrote:

> So, RX-ALL can be one flag, another for RX-FCS, and the TX-CUSTOM-FCS
> can be a separate patch altogether?

That is the basic idea, yes.

> Any problem with using the netdev->priv_flags to hold the RX-ALL and RX-FCS flags?

I see no problem with that.

Another option is to let the driver maintain the state bits
internally, but I see no reason to do that.

> Btw, it's impossible (afaik) to see the CRC errors generically w/out
> accessing netlink (which I assume works, but have never actually tried), ie
> there is no column in /proc/net/dev for rx-crc-errors.  It would be
> an excellent time to allow me to add the ethtool hook to read the
> net_device_stats struct via a single ioctl call! :)

The netlink thing does work, trust me :)
You could argue that 'ip -s link' should print this out, and I'd
agree with you on that.

However, one thing I want to make absolutely clear is that I do not
want multiple ways to get the same information out of the kernel.
We decided to build netlink into the kernel always because this means
it is present in everyone's kernel.  And therefore, we don't need to
add another way to obtain the same config information already
available via netlink.  The existing cases where an ioctl() style
call exists to obtain the same info available via netlink is merely
for compatability with older BSD tools.  No new such things will be
added.
