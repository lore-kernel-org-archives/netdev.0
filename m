From: Tom Herbert <therbert@google.com>
Subject: Re: [net-next 04/14] net: Fix issue with netdev_tx_reset_queue not
 resetting queue from XOFF state
Date: Fri, 20 Apr 2012 14:19:45 -0700
Message-ID: <CA+mtBx-BWy=KANgSca9f2vxuu1Km_kPMJbQFa+Nq9q_YYvatBQ@mail.gmail.com>
References: <1331611432-30109-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1331611432-30109-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:60079 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752970Ab2DTVTq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 17:19:46 -0400
Received: by iagz16 with SMTP id z16so13918921iag.19
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 14:19:45 -0700 (PDT)
In-Reply-To: <1331611432-30109-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

> @@ -3244,7 +3246,6 @@ static void igb_clean_tx_ring(struct igb_ring *=
tx_ring)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0buffer_info =3D &tx_ring->tx_buffer_in=
fo[i];
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0igb_unmap_and_free_tx_resource(tx_ring=
, buffer_info);
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 netdev_tx_reset_queue(txring_txq(tx_ring));
>
Why is it necessary to remove this?  If rings are being freed with
going through completion path then we would need this reset.  Is this
being done elsewhere maybe?

Tom
