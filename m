From: Jason Cooper <jason@lakedaemon.net>
Subject: Re: [PATCH v5 12/13] ARM: kirkwood: remove redundant DT board files
Date: Fri, 31 May 2013 07:54:50 -0400
Message-ID: <20130531115450.GA3803@titan.lakedaemon.net>
References: <1369154510-4927-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1369855975-21489-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1369855975-21489-13-git-send-email-sebastian.hesselbarth@gmail.com>
 <8738t4q1kv.fsf@natisbad.org>
 <20130530193708.GC31290@titan.lakedaemon.net>
 <87txlknluf.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Andrew Lunn <andrew@lunn.ch>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 David Miller <davem@davemloft.net>, Lennert Buytenhek <buytenh@wantstofly.org>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <87txlknluf.fsf@natisbad.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Arnaud,

On Fri, May 31, 2013 at 12:28:56AM +0200, Arnaud Ebalard wrote:
> Hi,
> 
> Jason Cooper <jason@lakedaemon.net> writes:
> 
> >> For instance 6bd98481ab34 (arm: kirkwood: NETGEAR ReadyNAS Duo v2 init
> >> PCIe via DT) currently sitting in jcooper/mvebu/pcie_kirkwood removes
> >> the PCIE init routine in board-readynas.c, and yours remove ge00
> >> init. With both applied, the whole file can go away.
> >> 
> >> AFAICT, this may be the case soon for:
> >> 
> >>  arch/arm/mach-kirkwood/board-iconnect.c   (36e5722089)
> >>  arch/arm/mach-kirkwood/board-mplcec4.c    (9470fbfb8d)
> >>  arch/arm/mach-kirkwood/board-nsa310.c     (40fa8e5da2)
> >>  arch/arm/mach-kirkwood/board-readynas.c   (6bd98481ab)
> >>  arch/arm/mach-kirkwood/board-ts219.c      (259e234608)
> >
> > Would you mind putting a patch together (for after v3.10 drops) to do
> > this?  If you applied Sebastian's series on top of mvebu/pcie_kirkwood,
> > that should get you almost there.  The last half of his series is going
> > in after v3.10...
> 
> Something like the quick quilt-generated patch at the end of this email
> (done after a dummy merge of Sebastian's set in mvebu/pcie_kirkwood)? 

yep.

> I will take a look at what remains after Sebastian's set hit one of
> your branch but I guess he will have included most of what is in the
> patch to help you with the merge.
> 
> Anyway, at the end here is what DT board files would remain:
> 
> $ ls -1 arch/arm/mach-kirkwood/board-*.c
> arch/arm/mach-kirkwood/board-dnskw.c

This one seems to just be setting a gpio to enable reboot after power
failure.  Should be simple to move to DT.

> arch/arm/mach-kirkwood/board-dt.c

We obviously need this one. ;-)

> arch/arm/mach-kirkwood/board-lsxl.c

This is taken care of in mvebu/boards

  391a16c ARM: Kirkwood: Convert LSXL to restart-poweroff driver.

> arch/arm/mach-kirkwood/board-ts219.c

Also in mvebu/boards

  4350a47 ARM: Kirkwood: Make use of the QNAP Power off driver.

> Just one question though: the removal of MACH_*_DT in Kconfig removes
> the automatic selection of useful board specific options like
> ARM_APPENDED_DTB, ARM_ATAG_DTB_COMPAT, POWER_RESET_RESTART,
> POWER_RESET_QNAP. Is that expected?

I would select POWER_RESET_QNAP and POWER_RESET_RESTART in Kconfig for
ARCH_KIRKWOOD_DT, and put ARM_APPENDED_DTB and ARM_ATAG_DTB_COMPAT into
the defconfig.

thx,

Jason.
