From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 03/10] MLSXFRM: Add security sid to sock
Date: Thu, 13 Jul 2006 09:59:06 -0400
Message-ID: <36282A1733C57546BE392885C06185920138E0D5@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@vger.kernel.org, jmorris@namei.org, tjaeger@cse.psu.edu,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:57160 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1751494AbWGMN7Y
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Jul 2006 09:59:24 -0400
To: Stephen Smalley <sds@tycho.nsa.gov>,
	Venkat Yekkirala <vyekkirala@TrustedCS.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Is it ever possible for the isec->sid and the sksec->sid to be
> inconsistent with one another?

I can't think of any possibility of this happening.

>  Could you just always return the
> sksec->sid here and avoid the need to grab the isec 
> altogether (dropping
> the requirement for sk_callback_lock at the same time, since you no
> longer need sk_socket)?

Will do.
> 
> Likewise, given sksec->sid, why don't you change sock_rcv_skb 
> to always
> use it, and eliminate the need for the isec and the sk_callback_lock
> there?

This is actually on my list of things to do already :) more for
the reason that this would help enforce controls on any data that
arrive for the socket between the time it's created and the time it's
accepted. Was planning to do this as part of the next patch reconciling
the various secids (IPSec, secmark, netlabel) per the design doc.

>   Similarly for postroute_last's use of isec->sid.  With direct
> labeling of the sock, it is no longer necessary to extract the isec.

Sure. Thanks.
