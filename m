From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek 8169 Lock-ups
Date: Sun, 11 Jan 2004 12:49:57 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040111124957.A18068@electric-eye.fr.zoreil.com>
References: <1073507006.5151.61.camel@localhost> <20040107232034.A22930@electric-eye.fr.zoreil.com> <1073596694.6378.6.camel@localhost> <4001080D.3090401@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dpollock@acm.org, netdev@oss.sgi.com, damouse@ntlworld.com,
        brad@mainstreetsoftworks.com, kinetik@orcon.net.nz
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4001080D.3090401@pobox.com>; from jgarzik@pobox.com on Sun, Jan 11, 2004 at 03:23:41AM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> :
[...]
> Have those already been tested?

Yes. Tester (damouse) included in Cc: list.
The patches improves the situation so that it is possible to bring the
interface up and send/receive traffic but something clearly smashes the
stack (if someone wants to check, .jpg panic and r8169 module available
at http://www.fr.zoreil.com/people/francois/misc/debug).

After the latest days of "patch/patch -R/change line foo into bar/...",
I have rediffed the whole serie of changes against 2.6.1 so M. Damouse can
test an identified set of patches and isolate the misbehaving one(s). It is
available at http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.1.

If people can reproduce the tests that M. Damouse made, it should look like:
apply r8169-dma-api-tx.patch
apply r8169-dma-api-rx-buffers.patch
apply r8169-dma-api-rx-buffers-ahum.patch
apply r8169-rx-fill-typo.patch
apply r8169-start-xmit-fixes.patch
apply r8169-dma-api-tx-buffers.patch
apply r8169-rx_copybreak.patch
-> So far, so good, no regression from classical driver
apply r8169-mac-phy-version.patch
apply r8169-buggy-devinitdata.patch
-> Seems fine but panics after a few ko of traffic

<blink>Confirmation, anyone ?</blink>

The set contains two extra/untested patches [*] wrt 2.6.1-bk1-netdev2. 
No need to push these further until the current issues are fixed imho.

M. Pollock's problems look different:
- they do not depend on the driver used;
- they seem timing/smp related (mobile computer + p4 HT).

[*]
r8169-addr-high.patch
r8169-ethtool-introduction.patch

--
Ueimor
