From: sjur.brandeland@stericsson.com
Subject: [RFC PATCH v3 0/8] CAIF Protocol Stack
Date: Mon, 30 Nov 2009 16:00:44 +0100
Message-ID: <1259593252-2493-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: randy.dunlap@oracle.com, kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, stefano.babic@babic.homelinux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:55100 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752311AbZK3QBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 11:01:22 -0500
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KTX001JFGDXKF10@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Mon, 30 Nov 2009 16:01:09 +0100 (CET)
Received: from localhost.localdomain ([84.49.68.131])
 by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KTX00IAMGDW9QV1@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Mon, 30 Nov 2009 16:01:09 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Braendeland <sjur.brandeland@stericsson.com>

This is the third RFC on the CAIF patch set. CAIF is the primary protoc=
ol
used to communicate between to ST-Ericsson modems and the external host=
 system.

=46eedback on the patch set is welcomed!

This time I have reworked the architecture a bit.
The Link Layers in CAIF are now proper NET Devices of type ETH_P_CAIF,
and Character Devices are replaced by CAIF Sockets.

This patch set is compiled on x86 for 2.6.32.

Issues:
* Line Discipline implementation is working on 2.6.28,
  but not on 2.6.32.
* A few known stability issues when running high load over TTY.
* Different physical layers types (e.g. SPI) are currently identified i=
n
  the "CAIF Protocol layer". CAIF Protocol layer should be ignorant
  of the kind of physical connection. This will be fixed later on.
* Too many log statements scattered throughout the code.
* Checks on LINUX_VERSION not yet removed.
* Global defines such as PF_CAIF, AF_CAIF, SOL_CAIF, N_CAIF, ETH_P_CAIF
  are defined locally as well. This duplication will be fixed  later on=
=2E
* CAIF Socket interface not all sockopt are implemented.
* RTNL configuration of CAIF is not yet tested.



Change Log:

General:
* Sockets has replaced the character device implementation,
  when accessing the modem. AT channels has to open sockets.
* CAIF Link layer is now implemented as net-devices.
* Cleanup of asserts no using caif_assert everywhere.
* Style cleanups, spacing, typedefs etc.

Documentation/CAIF
* Removed tool chardevconfig for configuration.
  Instead  CAIF NET device can be configured with RTNL or socket IOCTL.
* Removed replaced user space tool ldiscd to configure TTY.
  TTY is now opened from kernel when loading caif_serial.ko
* Added caif socket MAN page to Documentation (Will be moved later on).
* Added example on CAIF NET device configuration.
* Removed reference to  Doc No: 155 19-CRH 109 913.

include/linux
* Added caif_socket.h defining CAIF Socket interface.
* Added if_caif.h define CAIF IP Net Device configuration

include/net
* Added caif_dev.h defining interface between driver and caif-core.

include/net/generic
* Updated assert statement
* Removed typedefs

net/caif
* Added socket implementation and removed character device.
* General removed typedefs and fixed CHECKPATCH warnings
* Minor change on error handling in cfcnfg.c
* chnl_net.c Added RTNL support and IOCTL
* Fixed typos in Kconfig


I have merged feedback on previous patchset:

RE: [PATCH] [CAIF-RFC 0/8-v2] CAIF Protocol Stack
David Miller wrote:
> There is a lot of coding style issues here I'd like you to address in
> your next submission.
> Comments are formatted in several places like this:
>
> /*
> *
> *
> */
>
> It should be: ....
>
> /*
>  *
>  *
>  */
>
> Also often there are tons of extraneous empty lines in the source
> files.  Particularly right after the comment at the top of the source
> file.  For example include/net/caif/generic/cfcnfg.h there is the top
> comment (which needs to be fixed as described above) and then 8 empty
> lines before the #ifndef CFCNFG_H_ =20
>
> That's rediculious, just have one empty line there seperating things.
>
> Seriously, you should be able to just scan over your patch and see
> all of these oddities.  They jumped right out at me.  Please clean
> them up.=20
I think I have fixed up License statements and got rid of empty lines.=20
I'm afraid there are still style issues left, but I have tried to fix
those you pointed out and have ran checkpatch. Complaints on=20
LINUX_VERSION_CODE will be fixed in a later patch-set.


RE: [PATCH] [CAIF-RFC 1/8-v2] CAIF Protocol Stack
Stefano Babic wrote:
>> + * \b Documentation see STE Doc No: 155 19-CRH 109 913.
> Probably you should remove this line as you already did in other
> places.
Yes, agree - I have done so.

RE: [PATCH] [CAIF-RFC 2/8-v2] CAIF Protocol Stack
Stefano Babic wrote:
> You actually removed the shared memory driver. Do you plan to insert
> it again ?
Well,  yes and no. The shared memory driver is actually back on the cha=
rt,
and we  have support for more drivers internally,
but I want to start contributing the main CAIF protocol before releasin=
g more
drivers.

On the other hand, the CAIF protocol itself should not need to know the=
=20
type of physical link protocol. I intend to remove the references to ph=
ysical=20
layer types (e.g. SPI) later on.

> There are references to pictures that are not provided.
=46ixed: I have removed the references to the gifs.

>> +/* ASSERT */
>> +#define cfglu_assert(exp) BUG_ON(!(exp))
>
> I do not why, but even GENERIC_BUG is not defined for all
> architectures.
> This means that BUG_ON is simply removed by the compiler and we get
> no track if the assert fails.
> It should be better to add at least an internal trace (adding for
> example a CFLOG_FATAL call).
=46ixed: We have updated caif_assert with BUG_ON and printout.

> Is this file probably obsolete ?
Yes, but I'm not sure I'm able to remove all legacies right now.

>
> Not sure I have understood. There is an abstraction layer for SPI in
> kernel and some generic purpose functions are provided (spy_sync,
> spi_async, etc.) that are HW independent. I know they provide only
> the methods for the data transfer, but I have imagined that we need
> at this point some kind of "caif_spi_device" that is able to talk
> with the caif stack on one side and uses the functions in the SPI
> framework. In any case, HW independent. Have I missed something ?  =20

As mentioned above we have internally support for physical link layers=20
used for CAIF like SPI and others.
I hope we'll be able to contribute this in a later stage.
This is why the source code indicates support for things distributed.
But as previously mentioned, I'm planning to remove all references to=20
physical devices (except the Serial Driver) in the general CAIF part in=
=20
our next patch-set

RE: [PATCH] [CAIF-RFC 4/8-v2] CAIF Protocol Stack
Stefano Babic wrote:
> sjur.brandeland@stericsson.com wrote:
> s/happends/happens/, there are other occurencies.
Done, thanks
>
>> +
>> +bool cfcnfg_del_adapt_layer(struct _cfcnfg_t *cnfg, layer_t
>> +*adap_layer) { + uint8 channel_id =3D 0;
>> + struct cfcnfg_phyinfo *phyinfo =3D NULL;
>> + uint8 phyid =3D 0;
>> + CFLOG_TRACE(("cfcnfg: enter del_adaptation_layer\n")); +
>> + cfglu_assert(adap_layer !=3D NULL);
>> + channel_id =3D adap_layer->id;
>> + cfglu_assert(channel_id !=3D 0);
>
> My two cents about using assert in the code, but I prefer to get some
> info from system when something goes wrong as to call in some way
> panic (the assert calls BUG_ON) and blocks forever. This line is not
> different as checking the adapt_layer->dn pointer some lines after
> and I think an error is better recognized in that case. So IMHO
> should be better something like:  =20
>
> if (channel_id =3D=3D 0) {
> CFLOG_ERROR(("cfcnfg:adap_layer->dn is NULL\n"));
> return CFGLU_EINVAL;
> }
Ok, I have fixed this particular case as you have suggested.
I have also updated cfglu_assert to do printout before calling BUG_ON.
My thinking is to use asserts on internal in-variants. But error checki=
ng
on APIs e.g. between physical interface drivers and CAIF Stack should a=
t
least be proper checks as you suggested.
Please check what you think of the asserts in this release and get back=
 to be!

>
>> diff --git a/net/caif/generic/cfpkt_plain.c
> Probably you plan to use always the magic number in your buffer
> management. Then should be better to remove all the #if CHECK_MEM
> stuff.=20
The file cfpkt_plain.c is removed, the file cfpkt_pain.c should be
used instead.

RE: [PATCH] [CAIF-RFC 5/8-v2] CAIF Protocol Stack
Stefano Babic wrote:
> sjur.brandeland@stericsson.com wrote:
>> From: Sjur Braendeland <sjur.brandeland@stericsson.com>
>
> Hi Sjur,
>
>> diff --git a/net/caif/caif_chr.c b/net/caif/caif_chr.c
>
>> +#define caif_assert(assert) BUG_ON(!(assert))
>
> Do we need special assert for each module (cfglu_assert,
> caif_assert,...) ? They are all defined in the same way.
> At this point I have already set a comment about using BUG_ON in a
> previous patch.
OK, Fixed we should have 'caif_assert' all over.

>
> I see a mixed policy in this patch, using sometimes _assert and
> sometimes directly BUG_ON, too.
=46ixed.

>
>> + mutex_lock_interruptible(&dev->mutex);
> The return value is not checked and it must be, as in all other cases=
=2E
OK Fixed.


RE: [PATCH] [CAIF-RFC 5/8-v2] CAIF Protocol Stack
Randy Dunlap wrote:
>> diff --git a/net/caif/Kconfig b/net/caif/Kconfig new file mode 10064=
4
>> + Say Y here if you need to use a phone modem that uses CAIF as
>> +transport
>
> end above with period ('.').
OK, thanks.
>
>> + You will also need to say yes to any caif physical devices that
>> your platform + supports. + This can be either built-in or as a
>> loadable module, if you select +to build it as module
>
> s/,/;/
OK, thanks.
>
>> + the other CAIF also needs to built as modules
>
> the other CAIF {options or drivers or some other word here} also
> need  ... modules. (end with period)
>
>
=2E..
>> +
>> +config  CAIF_USE_PLAIN
>> + bool  "Use plain buffers instead of SKB in caif"
>> + default n
>> + ---help---
>> + Use plain buffer to transport data,
>
> s/,/./
OK, thanks.
>
=2E..
>> + Enable the inclusion of debug code in the caif stack,
>> + be aware that doing this will impact performance. + If unsure say
>> N here. +
>> +# Include physical drivers
>> +# source "drivers/net/caif/Kconfig"
>
> Drop the above line.
OK, thanks.


RE: [PATCH] [CAIF-RFC 6/8-v2] CAIF Protocol Stack
Stefano Babic wrote:
> s/disicpline/discipline/
OK, Removed the line discipline completely.
>
>> diff --git a/drivers/net/caif/phyif_loop.c
>
> Is there a reason why do you prefer to implement your own ring buffer
> management else to use the circ_buf already implemented in kernel ?
I've re-written and simplified this loopback device completely.
>
>> +#define phyif_assert(assert) BUG_ON(!(assert))
>
> Specialized assert function for this module, really needed ?
Nop, this has also gone.
>
>> +
>> + result =3D tty_register_ldisc(N_MOUSE, &phyif_ldisc);
>
> I think it is time to set up your own discipline include/linux/tty.h,
> inserting a N_CAIF line discipline. Reusing other discipline
> conflicts with other drivers.=20

OK, I will look into this.

RE: [PATCH] [CAIF-RFC 7/8-v2] CAIF Protocol Stack
Stefano Babic wrote:
> sjur.brandeland@stericsson.com wrote:
>> +ST-Ericsson modems support a number of transports between modem and
>> +host, currently Uart and Shared Memory are available for Linux.
>
> Shared Memory was removed in this patchset.
OK - s/Shared Memory/Loopback
>
>> +=3D=3D CAIF structure =3D=3D
>> +
>> +The goal is to have caif as system independent as possible.
>> +All caif code can be found under GenCaif/src and GenCaif/inc.
>
> The path are wrong, I think you mean net/caif/generic and
> include/net/caif.
OK - corrected path.
>
>> +The actual linux module implementation is under src/kernel.
>> +There is also a user space program that is not up to date to run th=
e
>> +stack in user space for testing.
>
> I think you can remove these phrases.
OK, done.
>
>> +
>> +We have tested the kernel implementation on the emulator with a
>> modem +and we are able to enumerate and make a link setup.
>
> Only as comment: I tested this patchset again on an ARM platform and
> I am able to send successfully AT commands to the Ericsson Test
> Device "B26".=20
Great! It is reassuring to hear that you're able to run CAIF :-)

>
>> +      - CFSHML CAIF Shared Memory layer.
>
> Again, this layer was removed and there is no track about SPI Layer.
Done, removed.
>
>> +To achieve this we need the help of a daemon program called ldiscd.
>> +The benefit is that we can hook up to any TTY, the downside is that
>> +we need an extra operation in order to install the line discipline.
>
> I understand the reason, it looks only a quite odd that we need to
> start only for this purpose a user space program. And there is no
> hint if the daemon is not started, simply caif does not work. What do
> you think to set up the line discipline directly in kernel ? =20

OK, I have removed the line discipline now and moved this code
into kernel. The tty to be used is now a module argument.

Ref. "Re: [PATCH] [CAIF-RFC 6/8-v2] CAIF Protocol Stack".

>> +Install the VEI channel (this will enumerate and do the linksetup
>> of the first VEI channel. If this goes well you should see
>> /dev/chn*) (There are printks logging all buffers that can be
>> checked with dmesg): +$ modprobe chnl_chr + +The AT (VEI) channel is
>> ready to use (you can now send AT commands on it):=20
>
> Not really. at this point, the channels are not configured if we do
> not use chardevconfig (or we do the same in kernel).

Agree, I have removed this paragraph.

>
>> diff --git a/Documentation/CAIF/caif_user_config.dox
>> b/Documentation/CAIF/caif_user_config.dox
>
> This file seems obsolete. There is no track about ACTIVATE/DEACTIVATE=
=2E
Yes, Agree I have removed this file completely.
This patch set removes the use of character devices for access and conf=
iguration,
and introduces Sockets and RTNL instead.

>> diff --git a/Documentation/CAIF/ldiscd/ldiscd.c
>> b/Documentation/CAIF/ldiscd/ldiscd.c
>> +#define CAIF_LDISC_TTY "/dev/ttyS0"
>
> I think it should not be bad to avoid a fixed device name and take it
> as program parameter.
Yes, agree. It is now a module paramter to caif_serial.c

BR/Sjur Br=E6ndeland
