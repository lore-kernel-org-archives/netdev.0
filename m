From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 1/2 v3] fs_enet/mii-fec.c: fix MII speed calculation
Date: Thu, 16 Jul 2009 16:37:31 -0600
Message-ID: <fa686aa40907161537t46f24258h5f320d196b715843@mail.gmail.com>
References: <1247578966-9847-1-git-send-email-wd@denx.de> <1247671133-12148-1-git-send-email-wd@denx.de>
	<fa686aa40907151017n76524708tdb028689adad4b5f@mail.gmail.com>
	<20090716212129.70710832E416@gemini.denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@ozlabs.org, Kumar Gala <galak@kernel.crashing.org>,
	netdev@vger.kernel.org
To: Wolfgang Denk <wd@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f184.google.com ([209.85.210.184]:35207 "EHLO
	mail-yx0-f184.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933013AbZGPWhx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 18:37:53 -0400
Received: by yxe14 with SMTP id 14so772029yxe.33
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2009 15:37:51 -0700 (PDT)
In-Reply-To: <20090716212129.70710832E416@gemini.denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 16, 2009 at 3:21 PM, Wolfgang Denk<wd@denx.de> wrote:
> Dear Grant Likely,
>
> In message <fa686aa40907151017n76524708tdb028689adad4b5f@mail.gmail.c=
om> you wrote:
>> On Wed, Jul 15, 2009 at 9:18 AM, Wolfgang Denk<wd@denx.de> wrote:
>> > The MII speed calculation was based on the CPU clock (ppc_proc_fre=
q),
>> > but for MPC512x we must use the bus clock instead.
>> >
>> > This patch makes it use the correct clock and makes sure we don't
>> > clobber reserved bits in the MII_SPEED register.
> ...
>> Drop the common code bit. =A0The 5200 and 5121 are different devices=
 and
>> it is a tiny bit of code. =A0I don't think there is any benefit to
>> having it as a common function. =A0Just roll the get_mii_speed funct=
ion
>> in the mii-fec driver itself.
>
> I don't like to see the code repeated - it makes maintenance harder
> and increases the memory footprint. But if you like it that way I'll
> do that.

Neither do I, but in this case has some mitigating factors.  diff stat
is interesting:

Old:
 arch/powerpc/include/asm/mpc5xxx.h   |   10 +++++++++
 arch/powerpc/sysdev/mpc5xxx_clocks.c |   37 ++++++++++++++++++++++++++=
++++++++
 drivers/net/fs_enet/mii-fec.c        |   13 +++++++++--
 drivers/net/fec_mpc52xx.c     |    2 +-
 drivers/net/fec_mpc52xx_phy.c |    6 ++++--
 5 files changed, 62 insertions(+), 6 deletions(-)

New:
 drivers/net/fs_enet/mii-fec.c |   35 +++++++++++++++++++++++++++++++--=
--
 drivers/net/fec_mpc52xx.c     |    2 +-
 drivers/net/fec_mpc52xx_phy.c |   21 ++++++++++++++++++---
 3 files changed, 50 insertions(+), 8 deletions(-)

If the two devices were somewhat related then my opinion might be
different.  However the combination of the tiny amount of calculation
code, the drivers being kept completely separate (or at least as
separate as they were before), the smaller code impact, and the lower
driver complexity (because the calculation code is inline instead of
in a different file) makes me like the second approach is better.

g.

--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
