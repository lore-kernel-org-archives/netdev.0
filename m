From: "Ralf E. Stranzenbach" <mobil@reswi.de>
Subject: AW: ksoftirqd uses 99% CPU triggered by network traffic (maybe RLT-8139 related)
Date: Tue, 10 Aug 2004 21:24:07 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OHEGLDMIEAEHODCFDBMAMEBLDJAA.mobil@reswi.de>
References: <20040809214548.GA20204@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Francois Romieu" <romieu@fr.zoreil.com>
In-Reply-To: <20040809214548.GA20204@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

i've applied these patches to a fresh linux 2.6.7 source set and moved only
the 8139too.c into my own (fresh) 2.6.7 kernel tree.

After rebuilding the modules i tried to run my usual test - sending a >1GB
file using Z-Modem (over a SSH connection). This test usually fails within
1-2 minutes on my system.

Using this patched driver everything works stable. So iA'm not enforced to
downgrade my system to a 2.4.x kernel :-)

This system is a ASUS A7V266 mainboard with two Realtek based network cards:

0000:00:0d.0 Ethernet controller: D-Link System Inc RTL8139 Ethernet (rev
10)
0000:00:0e.0 Ethernet controller: D-Link System Inc RTL8139 Ethernet (rev
10)

I tried another (Fiberline) network card but it had the same problems.

Many, many, many thanks.

Regards,
Ralf

-----Ursprungliche Nachricht-----
Von: Francois Romieu [mailto:romieu@fr.zoreil.com]
Gesendet: Montag, 9. August 2004 23:46
An: Ralf E. Stranzenbach
Betreff: Re: ksoftirqd uses 99% CPU triggered by network traffic (maybe
RLT-8139 related)


Ralf E. Stranzenbach <mobil@reswi.de> :
[...]
> i'm cured with the very same problem on my server machine. I tried for
help
> within the internet and googled this mail thread on the mail archives. But
i
> have some difficulties to understand, which patch should be applied to a
> vanilla 2.6.7 kernel to prevent this freezes.

I assume you have the same network adapter (i.e. 8139c).

Two patches are required:
1) ftp://ftp.kernel.org/pub/linux/kernel/v2.6/testing/patch-2.6.8-rc3.bz2
2)
ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.8-rc3/2.6.
8-rc3-mm2/2.6.8-rc3-mm2.bz2

Compile this kernel or extract the drivers/net/8139too.c file from it
into your favorite 2.6.x tree and give it a try.

Please Cc: your success/failure on netdev@oss.sgi.com.

--
Ueimor
