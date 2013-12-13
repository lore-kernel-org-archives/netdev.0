From: Ian Campbell <ijc@hellion.org.uk>
Subject: Bug#723177: Incompatible phys driven by Marvell phy driver?
Date: Fri, 13 Dec 2013 11:06:04 +0000
Message-ID: <1386932764.20787.85.camel@dagon.hellion.org.uk>
Reply-To: Ian Campbell <ijc@hellion.org.uk>, 723177@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Michal Simek <michal.simek@xilinx.com>, Stef van Os
 <stef.van.os@prodrive.nl>, Rick Hoover <RHoover@digilentinc.com>, Steven
 Wang <steven.wang@digilentinc.com>, Lars-Peter Clausen <lars@metafoo.de>,
 "David S. Miller" <davem@davemloft.net>, 723177@bugs.debian.org
To: netdev@vger.kernel.org
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.723177.B723177.138693278232760@bugs.debian.org>
List-URL: <http://lists.debian.org/debian-bugs-dist/>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

Hi,

In Debian bug #723177[0] Lennert Buytenhek reports[1] that the Marvell
phy driver tries to driver some Marvell phys which have differing
register layouts:
        
        The problem here was that the Marvell PHY driver at some point supported
        one or two specific Marvell ethernet PHY models, and people then started
        blindly adding new PHY IDs to it without checking whether the already
        supported PHYs and the PHYs for which support was being added had common
        register layouts (and they didn't).
        
        The result is that on some of the very common Marvell PHYs that this
        driver claims to support, the driver does sequences of register writes
        that have entirely different effects than the intended ones, causing
        various unintended side effects, including complete link failure, and
        e.g. on the quad ethernet PHY on some of the mv78xx0 development
        boards, having the Marvell PHY driver enabled causes link to flap on
        the other three ports if you plug/unplug one of the ports because the
        driver thinks it's a good idea to hard reset the whole chip under
        these circumstances...
        
        What needs to be done is that someone with access to the relevant
        Marvell datasheets fix the driver to behave according to which chip
        it's being used on.  It's quite a bit of work to sort out this mess,
        easily several tens of hours -- I started looking into it when I was
        still at Marvell, but didn't get it done before leaving.

I've tried to look into this but apparently most of the data sheets are
not publicly available, so I cannot even determine which phy's are being
driven incorrectly, let alone propose a fix. From my PoV it would be
sufficient to remove the incorrect PHYs from the phy table until they
are fixed properly.

I've CCd a bunch of people who have touched the driver, especially those
adding new Phys in the last couple of years. Do any of you have
sufficient access to datasheets to at least identify which PHYs might be
driven incorrectly?

Thanks,
Ian.

[0] http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=723177
[1] http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=723177#50
