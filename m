From: "Victor Miasnikov" <vvm@tut.by>
Subject: Kernel v3.2 used in SlackWare 14.00 please, backport all needed patches Re: [PATCH net, 1/2] hyperv: Fix a kernel warning from netvsc_linkstatus_callback()
Date: Thu, 23 May 2013 16:14:55 +0300
Message-ID: <00D0FAD3528A443BAEA3E39861B3CFAD@local.st.by>
References: <1365198280-23270-1-git-send-email-haiyangz@microsoft.com> <CACQ1gAi0JfJFAc822YT5xVfW8HkB8r_4rf0dXTNsi-1oChsPsQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="utf-8";
	reply-type=original
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>, <olaf@aepfle.de>,
	<jasowang@redhat.com>, <linux-kernel@vger.kernel.org>,
	<devel@linuxdriverproject.org>, <stable@vger.kernel.org>
To: "Richard Genoud" <richard.genoud@gmail.com>,
	"Haiyang Zhang" <haiyangz@microsoft.com>,
	"Patrick J. Volkerding" <volkerdi@slackware.com>,
	"KY Srinivasan" <kys@microsoft.com>,
	"Mike Sterling" <Mike.Sterling@microsoft.com>,
	"Olaf Hering" <ohering@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f43.google.com ([209.85.214.43]:40999 "EHLO
	mail-bk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758939Ab3EWNPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 09:15:00 -0400
Received: by mail-bk0-f43.google.com with SMTP id jm2so207199bkc.16
        for <netdev@vger.kernel.org>; Thu, 23 May 2013 06:14:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

> (the 3.2 version is different,
> and it's instaging. (at not used by distros anyway))

 No: used

Linux Kernel v3.2 used in:
-- SlackWare 14.00

This is actual stable version SlackWare

Please, backport all(!) needed patches

 I'm download https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.2.45.tar.xz

File ata_piix.c ( SHA1 ceaf441142ad3f6768ff71f023e73d0695458e2c ) from
./linux-3.2.45/drivers/ata/
not contain:
( even not contain sub-string "Hyper-V")
== ( VVM: symbol TAB replaced by Space+Space -- special for users of MS IE, MS OutLook [Express] )
static int prefer_ms_hyperv = 1;
module_param(prefer_ms_hyperv, int, 0);
MODULE_PARM_DESC(prefer_ms_hyperv,
  "Prefer Hyper-V paravirtualization drivers instead of ATA, "
  "0 - Use ATA drivers, "
  "1 (Default) - Use the paravirtualization drivers.");

static void piix_ignore_devices_quirk(struct ata_host *host)
{
#if IS_ENABLED(CONFIG_HYPERV_STORAGE)
  static const struct dmi_system_id ignore_hyperv[] = {
    {
      /* On Hyper-V hypervisors the disks are exposed on
       * both the emulated SATA controller and on the
       * paravirtualised drivers.  The CD/DVD devices
       * are only exposed on the emulated controller.
       * Request we ignore ATA devices on this host.
       */
      .ident = "Hyper-V Virtual Machine",
      .matches = {
        DMI_MATCH(DMI_SYS_VENDOR,
            "Microsoft Corporation"),
        DMI_MATCH(DMI_PRODUCT_NAME, "Virtual Machine"),
      },
    },
    { }  /* terminate list */
  };
  static const struct dmi_system_id allow_virtual_pc[] = {
    {
      /* In MS Virtual PC guests the DMI ident is nearly
       * identical to a Hyper-V guest. One difference is the
       * product version which is used here to identify
       * a Virtual PC guest. This entry allows ata_piix to
       * drive the emulated hardware.
       */
      .ident = "MS Virtual PC 2007",
      .matches = {
        DMI_MATCH(DMI_SYS_VENDOR,
            "Microsoft Corporation"),
        DMI_MATCH(DMI_PRODUCT_NAME, "Virtual Machine"),
        DMI_MATCH(DMI_PRODUCT_VERSION, "VS2005R2"),
      },
    },
    { }  /* terminate list */
  };
  const struct dmi_system_id *ignore = dmi_first_match(ignore_hyperv);
  const struct dmi_system_id *allow = dmi_first_match(allow_virtual_pc);

  if (ignore && !allow && prefer_ms_hyperv) {
    host->flags |= ATA_HOST_IGNORE_ATA;
    dev_info(host->dev, "%s detected, ATA device ignore set\n",
      ignore->ident);
  }
#endif
==


_Absolutly_ ( as _minimum_ for SlackWare 14.00 ) need backport requested at 2012-06-08(!) :
( look on sub-string "3.2")
==
----- Original Message ----- 
From: "Victor Miasnikov"
To: "Greg KH" ; "Jonathan Nieder" ; "Andy Whitcroft"
Cc: <stable@vger.kernel.org>; <linux-kernel@vger.kernel.org>; "KY Srinivasan"; "Mike Sterling"
Sent: Friday, June 08, 2012 1:36 PM
Subject: Re: Re: ToDo: backport to v3.4 , v3.3 , v3.2 patches 1b) db63a4c8115a libata 1) cd006086fa5d ata_piix: defer
disks to the Hyper-V drivers by default Fw: use hv_storvsc instead of ata_piix for IDE disks ( but not for the CD-ROM)

 . . .

{
> > > Hyper-V admins need _worked_ Linux v3.4.X / v3.3.X / v3.2.X
> > > Please, _fix_ errors related "use hv_storvsc instead of ata_piix to
> > > handle the IDE disks devices ( but not for the CD-ROM)"

  i.e. need backport to all actual version after 3.1

  cd006086fa5d ata_piix: defer disks to the Hyper-V drivers by default

and its prerequisite

  db63a4c8115a libata: add a host flag to ignore detected ATA devices
}
==

and not forget patch related Bug 52821 :

{{
== ==
----- Original Message ----- 
From: vvm
To: Andreas
Sent: Wednesday, January 30, 2013 4:20 PM
Subject: FIXed: ef773e1..bec35f4 Re: ata_piix.prefer_ms_hyperv=0 works Fw: Bug 52821 - ata_piix ATA_HOST_IGNORE_ATA for
Hyper-V also affects Virtual PC 7 https://bugzilla.novell.com/show_bug.cgi?id=737532 Or
https://bugzilla.kernel.org/show_bug.cgi?id=52821


Hi!

 Short:

> Still, if there is a way to cleanly identify Hyper-V but not Virtual PC 7, this would be great!

FIXed: ef773e1..bec35f4

 Write in
https://bugzilla.kernel.org/show_bug.cgi?id=52821

"please, backport to 3.4 . . . 3.6 . . . 3.7"

   . . .

 Full:



(
 . . .

> Still, if there is a way to cleanly identify Hyper-V but not Virtual PC 7, this would be great!

FIXed: ef773e1..bec35f4


----- Original Message ----- 
From: "Jeff Garzik"
To: "Olaf Hering"
Cc:  . . . ; "KY Srinivasan"
Sent: Wednesday, November 28, 2012 8:44 PM
Subject: Re: [PATCH] ata_piix: reenable MS Virtual PC guests

On 09/18/2012 11:48 AM, Olaf Hering wrote:
An earlier commit cd006086fa5d91414d8ff9ff2b78fbb593878e3c ("ata_piix:
defer disks to the Hyper-V drivers by default") broke MS Virtual PC
guests. Hyper-V guests and Virtual PC guests have nearly identical DMI
info. As a result the driver does currently ignore the emulated hardware
in Virtual PC guests and defers the handling to hv_blkvsc [ VVM: in current ver kernel -- hv_storvsc ]  . Since Virtual
PC does not offer paravirtualized drivers no disks will be found in the
guest.

One difference in the DMI info is the product version. This patch adds a
match for MS Virtual PC 2007 and "unignores" the emulated hardware.

This was reported for openSuSE 12.1 in bugzilla:
https://bugzilla.novell.com/show_bug.cgi?id=737532
.  .  .

Signed-off-by: Olaf Hering

applied.  Apologies for missing this one.  It was accidentally shifting
into the low-priority pile.
==


== ==


==
Andreas 2013-01-30 22:19:21
  First appearance:
https://bugzilla.novell.com/show_bug.cgi?id=737532
Patch:
https://lkml.org/lkml/2012/9/18/306

==

}}




> This should also go to the stable tree, shouldn't it ?
> At least 3.8, 3.7 and 3.4

 In kernel 3.2 used in

-- Ubuntu 12.4.0 LTS (  after 12.4.2 -- 3.5.X)
and
-- Debian 7.0

source code related Hyper-V backported from "vanila" Kernel v3.5 ( and someone from hi versions)

Please, ask Support Teams of Debian and Ubuntu for backport



Best regards, Victor Miasnikov
Blog:  http://vvm.blog.tut.by/


P.S.

to To Microsoft Hyper-V for Linux Team:

what are mint phrase:
"LIS (Linux Integration Services) 4.0"
?

If need details -- ask me by e-mail . . .



P.P.S.

Again to To Microsoft Hyper-V for Linux Team:

 See on MS Forum topic
"Linux VM literally crashes Hyper-V host server with STOP 0x00020001"
 and (or)
please, remember, CVE number



P.P.P.S.

To SUSE Hyper-V for Linux Team:

Olaf, I'm received Yours e-mail msg ( answer on my earler msg)

 Thanks for answer

Unfortunately Yours ( SUSE/Novel) Bug-Tracker not opened by IE from Win Srv Edtions
I'm try do it from OpenSUSE v12.3 LiveCD but can not boot from it in Hyper-V VM when "Dynamic memory" turn on

 See details on
http://vvm.blog.tut.by/2013/05/18/opensuse-on-hyper-v/

 Or ask SUSE Support Team write me by e-mail for detail


P.P.P.P.S.

 In
./linux-3.10-rc2/drivers/scsi/storvsc_drv.c

I am not found sub-string "Fiber Channel"

  As I  undestand Linux Kernel roadmap/timeline traditions
need ask by backport needed patches to v3.10

To Microsoft Hyper-V for Linux Team:

 Who must do it?

Again Hypev-V sysadmin[s] ?


P.P.P.P.P.S.

Sorry, if my msg not full "political correct"

I preffered solve problem as possibily earler, what wait big problems

Sorry, again . . .
