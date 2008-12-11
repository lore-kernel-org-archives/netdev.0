From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [PATCH][RFC 21/23]: iSCSI target driver
Date: Thu, 11 Dec 2008 14:59:56 -0800
Message-ID: <1229036396.4153.588.camel@haakon2.linux-iscsi.org>
References: <494009D7.4020602@vlnb.net>  <49401205.8010207@vlnb.net>
	 <1229036109.4153.585.camel@haakon2.linux-iscsi.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-scsi@vger.kernel.org,
	James Bottomley <James.Bottomley@HansenPartnership.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Jeff Garzik <jeff@garzik.org>,
	Boaz Harrosh <bharrosh@panasas.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, scst-devel@lists.sourceforge.net,
	Bart Van Assche <bart.vanassche@gmail.com>,
	netdev@vger.kernel.org, Rafiu Fakunle <rafiu@openfiler.com>
To: Vladislav Bolkhovitin <vst@vlnb.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759447AbYLKXAh@vger.kernel.org>
In-Reply-To: <1229036109.4153.585.camel@haakon2.linux-iscsi.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2008-12-11 at 14:55 -0800, Nicholas A. Bellinger wrote:
> On Wed, 2008-12-10 at 22:01 +0300, Vladislav Bolkhovitin wrote:
> > This patch contains iSCSI-SCST target driver. This driver is a heavily 
> > modified forked with all respects IET 
> > (http://iscsitarget.sourceforge.net). Modifications were aimed to make a 
> > clearer, more reviewable and maintainable code as well as to fix many 
> > problems and make many improvements. See 
> > http://scst.sourceforge.net/target_iscsi.html for more details.
> > 
> > It has split user/kernel space architecture, where all management, 
> > sessions creation, parameters negotiation, etc. made in user space and 
> > data are transferred in the kernel space. Such architecture for iSCSI 
> > processing was many times acknowledged as the right one. Particularly, 
> > in-kernel iSCSI initiator (open-iscsi) has such architecture.
> > 
> 
> Just as with the Open/iSCSI Initiator, IMHO I believe the split
> architecture design is difficult both to improve, debug and maintain,
> and provides *ZERO* additional benefit in the context of traditional
> iSCSI target mode for doing login and connection/session setup in
> userspace.
> 
> Also, I appericate that you spent alot of time porting over IET code to
> your engine, but during our previous discussion you did not seem
> terribly interested in validation against core-iscsi-dv
> (http://linux-iscsi.org/index.php/Core-iscsi-dv) to test RFC-3720
> interopt and stability.  Because the Core-iSCSI Initiator supports every
> possible parameter combination up to ErrorRecoveryLevel=0 defined in
> RFC-3720, the Core-iSCSI-Dv tests can run badblocks (or any too) to
> check data integrity for *EVERY* possible traditional iSCSI key
> combination and functionality for your iSCSI-SCST work, and any type of
> serious iSCSI-SCST production deployments.
> 
> Until you can at least do that to prove both the stability and
> completeness of your iSCSI Target stack up to RFC-3720
> ErrorRecoveryLevel=0, I don't think this code makes sense for any type
> of mainline acceptance.  Also, I would appericate if you could stop the
> handwaving about MC/S and ErrorRecoveryLevel=2 as well.  MC/S (multiple
> connection paths for iSCSI/TCP, not necessary with multiple assoication
> LIO-Target SCTP) and ERL=2 (OS independent fabric recovery) is available
> in both RFC-3720 (Traditional iSCSI) and RFC-5045 (iSER for iWARP and
> IB).
> 

That was RFC-5046 for iSER note btw, RFC-5045 is the actual case for
RDMA/DDP over TCP and the Stream Control Transfer Protocol (SCTP).

Regards,

--nab


> Trying to argue against implementing the complete iSCSI RFC
> functionality (like some folks did during the early Open/iSCSI days)
> that customers and users *WANT* now is going to fall of deaf ears.
> Please understand that they are going to be many, many different iSCSi
> Initiators connecting to the upstream iSCSI Target Core infrastructure,
> and trying to rush in an incomplete iSCSI Target $FABRIC_MOD
> implementation benefits anyone.
> 
> Regards,
> 
> --nab
> 
> > Signed-off-by: Vladislav Bolkhovitin <vst@vlnb.net>
> > ---
> >   drivers/scst/iscsi-scst/Kconfig     |   25
> >   drivers/scst/iscsi-scst/Makefile    |    6
> >   drivers/scst/iscsi-scst/config.c    |  597 +++++++
> >   drivers/scst/iscsi-scst/conn.c      |  488 +++++
> >   drivers/scst/iscsi-scst/digest.c    |  221 ++
> >   drivers/scst/iscsi-scst/digest.h    |   31
> >   drivers/scst/iscsi-scst/event.c     |  116 +
> >   drivers/scst/iscsi-scst/iscsi.c     | 3066 ++++++++++++++++++++++++++++++++++++
> >   drivers/scst/iscsi-scst/iscsi.h     |  577 ++++++
> >   drivers/scst/iscsi-scst/iscsi_dbg.h |   73
> >   drivers/scst/iscsi-scst/iscsi_hdr.h |  517 ++++++
> >   drivers/scst/iscsi-scst/nthread.c   | 1522 +++++++++++++++++
> >   drivers/scst/iscsi-scst/param.c     |  263 +++
> >   drivers/scst/iscsi-scst/session.c   |  210 ++
> >   drivers/scst/iscsi-scst/target.c    |  306 +++
> >   include/scst/iscsi_scst.h           |  156 +
> >   include/scst/iscsi_scst_ver.h       |   16
> >   17 files changed, 8190 insertions(+)
> > 
> > The patch is too big to be submitted inline. You can find it in 
> > http://scst.sourceforge.net/patches/iscsi-scst.diff
> > 
> > 
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-scsi" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-scsi" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
