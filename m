From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 7/7] secid reconciliation-v02: Enforcement for SELinux
Date: Mon, 18 Sep 2006 15:15:11 -0400
Message-ID: <36282A1733C57546BE392885C061859201572F5D@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	Chad Hanson <chanson@TrustedCS.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:388 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1751666AbWIRTPb
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 15:15:31 -0400
To: James Morris <jmorris@namei.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Fri, 8 Sep 2006, Venkat Yekkirala wrote:
> 
> > +	if (selinux_compat_net) {
> > +		err = selinux_xfrm_decode_session(skb, &peersid, 0);
> > +		BUG_ON(err);
> 
> I'm pretty sure this should not be a BUG_ON.  IIUC, you want 
> to panic the 
> kernel because one of the nested SAs has a different security context.

No, we are sending in 0 for the ckall param by which we are telling
the function NOT to do any checks, but to simply set the return param
peersid to the secid on the first xfrm if any and succeed by returning 0.
Must not fail.
