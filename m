From: Johannes Thumshirn <jthumshirn@suse.de>
Subject: Re: [RFC 1/6] qed: Add support for hardware offloaded iSCSI.
Date: Thu, 20 Oct 2016 09:09:01 +0200
Message-ID: <20161020070901.52tm2d255dquocho@linux-x5ow.site>
References: <1476853273-22960-1-git-send-email-manish.rangankar@cavium.com>
 <1476853273-22960-2-git-send-email-manish.rangankar@cavium.com>
 <20161019090923.up3xgrbya3mxr7vu@linux-x5ow.site>
 <alpine.LRH.2.00.1610191538530.25712@mvluser05.qlc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: manish.rangankar@cavium.com, lduncan@suse.com, cleech@redhat.com,
        martin.petersen@oracle.com, jejb@linux.vnet.ibm.com,
        linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
        Yuval.Mintz@cavium.com, QLogic-Storage-Upstream@cavium.com,
        Yuval Mintz <Yuval.Mintz@qlogic.com>
To: Arun Easi <arun.easi@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40512 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751481AbcJTHJE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Oct 2016 03:09:04 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.00.1610191538530.25712@mvluser05.qlc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Arun,

On Wed, Oct 19, 2016 at 05:14:59PM -0700, Arun Easi wrote:
> Thanks Johannes for the review, please see my response below.
> 

[...]

> > 
> > Why not introduce a small helper like:
> > static inline bool qed_is_iscsi_personality()
> > {
> > 	return IS_ENABLED(CONFIG_QEDI) && p_hwfn->hw_info.personality ==
> > 		QED_PCI_ISCSI;
> > }
> 
> I think I can remove the IS_ENABLED() check in places like this
> and have the check contained in header file. qed_iscsi_free()
> already is taken care, if I do the same fore qed_ooo*, I think
> the check would just be "p_hwfn->hw_info.personality ==
> QED_PCI_ISCSI", which would keep it consistent with the other
> areas where similar check is done for other protocols.

Sounds good.

> 

[...]

> > 
> > Is there any chance you could factor out above blocks into own functions so
> > you have
> > 
> > 
> > 	if (!GET_FIELD(p_ramrod->iscsi.flags,
> > 		       ISCSI_CONN_OFFLOAD_PARAMS_TCP_ON_CHIP_1B)) {
> > 		qedi_do_stuff_off_chip();
> > 	else 
> > 		qedi_do_stuff_on_chip();
> > 
> 
> This function mostly fills data needed for the firmware interface.
> By having all data necessary for the command
> ISCSI_RAMROD_CMD_ID_OFFLOAD_CONN in this function it is easier to
> refer what is being fed to firmware. If you do not have strong
> objections, I would like to keep it this way.

No strong objections, I just don't think these lengthy blocks are readable,
but I don't want to do too much bikeshedding about it.

Thanks,
	Johannes

-- 
Johannes Thumshirn                                          Storage
jthumshirn@suse.de                                +49 911 74053 689
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nürnberg
GF: Felix Imendörffer, Jane Smithard, Graham Norton
HRB 21284 (AG Nürnberg)
Key fingerprint = EC38 9CAB C2C4 F25D 8600 D0D0 0393 969D 2D76 0850
