From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [Bug 3904] New: CHECKSUM_HW gets set even w/o hardware support.
Date: Thu, 16 Dec 2004 11:08:17 -0800
Message-ID: <20041216110817.0d3a78d4@dxpl.pdx.osdl.net>
References: <200412150642.iBF6geO1013040@fire-1.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: tcc_linux@thinkthink.com
In-Reply-To: <200412150642.iBF6geO1013040@fire-1.osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 14 Dec 2004 22:42:40 -0800
bugme-daemon@osdl.org wrote:

> http://bugme.osdl.org/show_bug.cgi?id=3904
> 
>            Summary: CHECKSUM_HW gets set even w/o hardware support.
>     Kernel Version: 2.6.9
>             Status: NEW
>           Severity: normal
>              Owner: shemminger@osdl.org
>          Submitter: tcc_linux@thinkthink.com
> 
> 
> Distribution:
>    Debian w/ kernel from kernel.org
> Hardware Environment:
>    Fujitsu LifeBook N5010
> Software Environment:
>    Debian unstable distro
> Problem Description:
>    CHECKSUM_HW is improperly set in udp.c resulting in udp frames being sent
> with bad checksums. The hardware and therefore the driver (8139cp) is not
> setting CHECKSUM_HW (I checked). Possibly a problem with any NIC that doesn't do
> hardware checksumming. #if 0'ing out the hw checksum code in
> udp.c:udp_push_pending_frames() works as a workaround (but obviously does not
> identify who set CHECKSUM_HW).
> Steps to reproduce:
>    Need board that uses 8139cp driver. Write a small program that sends udp
> data. Observe with tcpdump.  Sendto, send, and write all behave the same.
> Tcpdump also has a problem displaying what the checksum should be, but does
> properly flag the bad checksum.
> 
> ------- You are receiving this mail because: -------
> You are the assignee for the bug, or are watching the assignee.

I believe the problem is that the 8139cp driver allows enabling TX csum,
via ethtool but does not support it.  What does ethtool report as being
enabled on that ethernet. I doubt it is a udp problem.
