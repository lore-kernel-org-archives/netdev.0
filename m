From: Donald Becker <becker@scyld.com>
Subject: Re: [ANNOUNCE] NAPI patches for 2.4.19-rc1
Date: Wed, 10 Jul 2002 20:41:59 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0207102019160.2498-100000@beohost.scyld.com>
References: <Pine.GSO.4.30.0207101917480.22734-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <Pine.GSO.4.30.0207101917480.22734-100000@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org

On Wed, 10 Jul 2002, jamal wrote:
...
> For the best perfomance (at least on the Znyx Nics) turn on MMIO
> (selected from kernel config). Ignore anything that looks strange
> in the code. The dl2k and sundance driver from Ed Peng listed in the
> README at the site should work fine on 2.4

Ehhh?  Has anyone tested that sundance driver with the Kendin chip using
the on-chip transceiver?  I'm guessing that it doesn't work.

And, BTW, I don't like some of the driver changes in that version.

One pair of changes that represent "it works for me" code and flawed
reasoning is resetting the transceiver and then calling mdelay(300).

Unless there is a specific known hardware problem, the driver should not
reset the transceiver and thus re-do autonegotiation.  Some switches
(Cisco) turn off traffic to that port for a minute when link beat is
lost, and some operations rely on being able to rapidly bring the
interface up and down.

The mdelay(300) is completely bogus.  While that is a typical period for
autonegotiation to complete on a short link, the spec says that it can
take up to 3 seconds, 10X longer, to complete autonegotiation.  Given
that the driver must be able to handle a longer autonegotiation period
and no link beat, why call mdelay() at all?

The driver also changes the transceiver settings to non-standard
values.  Yes, the change might seem more descriptive, but the modified
driver doesn't match the documentation or accept the options that other
drivers do.  There is a value to consistency: "/bin/list" is more
descriptive than  "/bin/ls", but you don't see any distribution trying
to rename 'ls'... 

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Second Generation Beowulf Clusters
Annapolis MD 21403			410-990-9993
