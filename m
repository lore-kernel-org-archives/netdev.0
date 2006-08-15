From: Paul Mackerras <paulus@samba.org>
Subject: Re: ehea debug output discussion
Date: Tue, 15 Aug 2006 15:10:25 +1000
Message-ID: <17633.22337.802294.171558@cargo.ozlabs.ibm.com>
References: <44D99F38.8010306@de.ibm.com> <20060811215225.GH479@krispykreme>
	<44DE03B0.1060607@de.ibm.com> <20060813144400.GJ479@krispykreme>
	<44E06EDA.6040404@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Klein <tklein@de.ibm.com>, Jan-Bernd Themann <themann@de.ibm.com>,
	roland@topspin.com, netdev <netdev@vger.kernel.org>,
	Thomas Klein <osstklei@de.ibm.com>, linux-ppc <linuxppc-dev@ozlabs.org>,
	Christoph Raisch <raisch@de.ibm.com>, Anton Blanchard <anton@samba.org>,
	Marcus Eder <meder@de.ibm.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
In-Reply-To: <44E06EDA.6040404@de.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Jan-Bernd Themann writes:

> The outcome of some internal discussions was that it is not acceptable for
> our enterprise users of this type of driver on this target system to need a
> recompile / reload of the driver for error analysis, so we need a mechanism
> that allows us to switch on / off debug output at runtime. Therefore, we'd
> introduce a stripped down version of EDEB.

This is precisely what kprobes is for.  There is no need for
EDEB-style debug code in the source given that kprobes gives you the
ability to add logging in at (almost) arbitrary points at runtime.  In
fact kprobes is more powerful because you don't have to specify the
set of points of interest when the kernel is built--you can do it
later, at the time of debugging.

Please look into providing a kprobes module and/or a systemtap script
for the debugging points you want rather than cluttering up the source
code with EDEB statements.

Paul.
