From: "Ramachandra K" <ramachandra.kuchimanchi@qlogic.com>
Subject: Re: [ofa-general] Re: [PATCH 01/13] QLogic VNIC: Driver - netdev implementation
Date: Mon, 5 May 2008 21:06:58 +0530
Message-ID: <71d336490805050836o68d745f2k4bab68edcfe1da50@mail.gmail.com>
References: <20080430171028.31725.86190.stgit@localhost.localdomain>
	 <20080430171624.31725.98475.stgit@localhost.localdomain>
	 <adaiqxw4lox.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, poornima.kamath@qlogic.com,
	general@lists.openfabrics.org, amar.mudrankit@qlogic.com
To: "Roland Dreier" <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.186]:16169 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751682AbYEEPhB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 11:37:01 -0400
Received: by gv-out-0910.google.com with SMTP id e6so131687gvc.37
        for <netdev@vger.kernel.org>; Mon, 05 May 2008 08:36:58 -0700 (PDT)
In-Reply-To: <adaiqxw4lox.fsf@cisco.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland,

Thanks for the review. Your comments make sense and we will fix the
things you pointed out. Please see some clarifications in-line.

On Fri, May 2, 2008 at 11:45 PM, Roland Dreier <rdreier@cisco.com> wrote:
>  > From: Ramachandra K <ramachandra.kuchimanchi@qlogic.com>
>   >
>   > Signed-off-by: Poornima Kamath <poornima.kamath@qlogic.com>
>   > Signed-off-by: Amar Mudrankit <amar.mudrankit@qlogic.com>
>
>  For the next submission please clean up the From and Signed-off-by
>  lines.  As it stands now you are saying that you (Ramachandra K) are the
>  author of the patch, and that Poornima and Amar signed off on it (ie
>  forwarded it), but you as the person sending the email did not sign off
>  on it.
>

I will make sure to sign off on all patches. Should I also drop the From line
for the patches which I developed, since I am mailing them myself ?

I am using the Signed-off-by line to indicate the people who were
involved in the development of the patches at some stage.

>
>
>   > +void vnic_stop_xmit(struct vnic *vnic, struct netpath *netpath)
>   > +{
>   > +    VNIC_FUNCTION("vnic_stop_xmit()\n");
>   > +    if (netpath == vnic->current_path) {
>   > +            if (vnic->xmit_started) {
>   > +                    netif_stop_queue(vnic->netdevice);
>   > +                    vnic->xmit_started = 0;
>   > +            }
>   > +
>   > +            vnic_stop_xmit_stats(vnic);
>   > +    }
>   > +}
>
>  Do you have sufficient locking here?  Could vnic->current_path or
>  vnic->xmit_started change after they are tested, leading to bad results?
>  Also do you get anything from having a xmit_started flag that you
>  couldn't get just by testing with netif_queue_stopped()?
>

You are right, xmit_started might not be required and we will look at
the locking
issue too.

>
>
>   > +extern cycles_t recv_ref;
>
>  seems like too generic a name to make global.  What the heck are you
>  using cycle_t to keep track of anyway?
>

This is being used as part of the driver internal statistics
collection to keep track of the time
elapsed between a message arriving from the EVIC indicating that it
has done an RDMA write of
an Ethernet packet to the driver memory and the driver giving the packet
to the network stack.  Will fix the variable name.

Regards,
Ram
