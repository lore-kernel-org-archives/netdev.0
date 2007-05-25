From: =?iso-8859-1?b?RW1tYW51ZWwgRnVzdOk=?= <emmanuel.fuste@laposte.net>
Subject: Re: [AIC7xxx] tree things to report
Date: Fri, 25 May 2007 11:06:29 +0200
Message-ID: <JILAMT$6007FAE08113F3B8F9C4C1653EE14701@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.laposte.net ([81.255.54.16]:11713 "EHLO mx.laposte.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751267AbXEYJZD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2007 05:25:03 -0400
Received: from smtp.laposte.net (10.150.9.33) by mx.laposte.net (7.2.060.1)
        id 45FFE58C020E47F4 for netdev@vger.kernel.org; Fri, 25 May 2007 11:04:07 +0200
Received: from smtpin.laposte.net (10.150.9.72) by smtp.laposte.net (7.3.118.3)
        id 462F99F403494360 for netdev@vger.kernel.org; Fri, 25 May 2007 11:04:07 +0200
Received: from laposte.net (10.150.9.81) by smtpin.laposte.net (7.2.060.1)
        id 45FA4DCC0061569C for netdev@vger.kernel.org; Fri, 25 May 2007 11:04:07 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
While trying to obtain scsi log to debug a driver problem, I
tried to use netconsole on an old smp system with a 10Mbits
pcnet32 ethernet device.
But few seconds after enabling netconsole, before launching my
scsi test, but after a few console activity the computer
freeze hard.
Is it a know or expected problem ? (2.6.21 kernel, pcnet32:
PCnet/PCI 79C970) Have you some solutions or patch to try ?
Will get back my soldering iron to do a serial cable for now.

Thanks,
Emmanuel.

> Hi Emmanuel,
>=20
> Emmanuel Fust=E9 wrote:
> > Hello,
> >=20
> > After one year of rest, I resurrect my old computer, install a
> > 2.6.21 kernel and updated my Debian distro.
> >=20
> > Tree things to repport:
> >=20
> > First, a cosmetic thing: I have two scsi sync devices and two
> > async devices. For the first ones, domain validation return
> > the negociated speed and mode. For the second ones, domain
> > validation return nothing. I expect it is just a 'missing
> > feature' but that all went ok. I am right ?
> >=20
> > scsi0 : Adaptec AIC7XXX EISA/VLB/PCI SCSI HBA DRIVER, Rev 7.0
> >         <Adaptec 2940 Ultra2 SCSI adapter>
> >         aic7890/91: Ultra2 Wide Channel A, SCSI Id=3D7,
32/253 SCBs
> >=20
> > scsi 0:0:0:0: Direct-Access     IBM      DMVS18V         02B0
> > PQ: 0 ANSI: 3
> > scsi0:A:0:0: Tagged Queuing enabled.  Depth 8=20
> >  target0:0:0: Beginning Domain Validation
> >  target0:0:0: wide asynchronous
> >  target0:0:0: FAST-40 WIDE SCSI 80.0 MB/s ST (25ns, offset 31)
> >  target0:0:0: Domain Validation skipping write tests
> >  target0:0:0: Ending Domain Validation
> > scsi 0:0:3:0: CD-ROM            YAMAHA   CRW6416S         1.0d
> > PQ: 0 ANSI: 2
> >  target0:0:3: Beginning Domain Validation
> >  target0:0:3: FAST-10 SCSI 10.0 MB/s ST (100 ns,offset 15)
> >  target0:0:3: Domain Validation skipping write tests
> >  target0:0:3: Ending Domain Validation
> > scsi 0:0:4:0: CD-ROM            TOSHIBA  CD-ROM XM-3501TA 1875
> > PQ: 0 ANSI: 2
> >  target0:0:4: Beginning Domain Validation
> >  target0:0:4: Domain Validation skipping write tests
> >  target0:0:4: Ending Domain Validation
> > scsi 0:0:6:0: Sequential-Access WANGTEK  5525ES SCSI REV7 0W=20
> >  PQ: 0 ANSI: 1
> >  target0:0:6: Beginning Domain Validation
> >  target0:0:6: Ending Domain Validation
> >=20
> Hmm. Have to have a look at it. It should at least report
the result ...
>=20
> > Secondly, It seems that something is doing weird things with
> > my old CD-ROM reader (XM-3501TA). At some point in time (not
> > really regular), I get this in my logs:
> > May 23 00:45:44 rafale kernel: (scsi0:A:4:0): No or incomplete
> > CDB sent to device.
> > May 23 00:45:44 rafale kernel: (scsi0:A:4:0): Protocol
> > violation in Message-in phase.  Attempting to abort.
> > May 23 00:45:44 rafale kernel: (scsi0:A:4:0): Abort
Message Sent
> > May 23 00:45:44 rafale kernel: (scsi0:A:4:0): SCB 11 - Abort
> > Completed.
> > And sometimes (but seem related to problems with my cable):
> > May 23 04:32:49 rafale kernel: (scsi0:A:4:0): parity error
> > detected in Status phase. SEQADDR(0xad) SCSIRATE(0x0)
> > May 23 05:13:03 rafale kernel: (scsi0:A:4:0): parity error
> > detected in Status phase. SEQADDR(0xac) SCSIRATE(0x0)
> >=20
> Yes, this looks like a cable probrlem.
>=20
> > There is no scsi bus freeze, and the device work perfectly
> > without generating other errors. DV problem ? Bad hal daemon
> > interaction ? Defect in the driver trigged by bad hal daemon
> > behavior ?=20
> >=20
> Ach, yes, it could at least be triggered by hal. Not all
devices like to
> be polled by hal, especially if they're in a middle of an
operation.
> CD-RW eg. Kay claimed to have it solved, but I still end up
disabling
> hal :-)
>=20
> > Last thing, a now two years problem:
> > cdrwtools -d /dev/sr0 -q still instantly crash the
> > scsibus/cdwriter and the driver never recover.
> > I did not have a new log because of the complete bus crash.
> > Have you new ideas about this problem ??
> No, not yet. But it looks as if I finally got some time to
look deeper
> in this problem.
> Bugzilla's still assigned to me, to it's a constant
remainder that
> something's amiss ...
>=20
> > I will try:
> > - to get a log on a usb key
> > - to port patch from Bugzilla Bug 5921 to current kernel. With
> > the previous ones, the driver recover. (but i was experiencing
> > FS corruption but it seems it was not related).
> > - to identify exactly what cdrwtools send to the kernel/driver
> > which cause the crash.
> What you should do here is:
>=20
> - hook up a serial cable and re-route console messages to that
> - Switch off syslog (as this might block if the SCSI bus frozen)
> - Enable scsi debugging (Error, Timeout, Scan, and Midlayer is
> sufficient) and start cdrwtools.
> - Send me the log from the serial console.
>=20
> This will give me at least a starting point what's going wrong.
>=20
> Thanks for your patience.
>=20
> Cheers,
>=20
> Hannes
> --=20
> Dr. Hannes Reinecke		      zSeries & Storage
> hare@suse.de			      +49 911 74053 688
> SUSE LINUX Products GmbH, Maxfeldstr. 5, 90409 N=FCrnberg
> GF: Markus Rex, HRB 16746 (AG N=FCrnberg)
>=20

---

Cr=E9ez votre adresse =E9lectronique prenom.nom@laposte.net=20
1 Go d'espace de stockage, anti-spam et anti-virus int=E9gr=E9s.


---

Cr=E9ez votre adresse =E9lectronique prenom.nom@laposte.net=20
1 Go d'espace de stockage, anti-spam et anti-virus int=E9gr=E9s.

