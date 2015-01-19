From: "Harout Hedeshian" <harouth@codeaurora.org>
Subject: RE: [PATCH net-next] net: ipv6: Add sysctl entry to disable MTU updates from RA
Date: Mon, 19 Jan 2015 14:31:37 -0700
Message-ID: <000d01d0342f$4ee4f740$ecaee5c0$@codeaurora.org>
References: <1421456558-27144-1-git-send-email-harouth@codeaurora.org> <20150119.155807.377681769985591321.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-7"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: "'David Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:53633 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345AbbASVbj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 16:31:39 -0500
In-Reply-To: <20150119.155807.377681769985591321.davem@davemloft.net>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, January 19, 2015 1:58 PM
> To: harouth@codeaurora.org
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH net-next] net: ipv6: Add sysctl entry to disable MTU
> updates from RA
> 
> From: Harout Hedeshian <harouth@codeaurora.org>
> Date: Fri, 16 Jan 2015 18:02:38 -0700
> 
> > The kernel forcefully applies MTU values received in router
> > advertisements provided the new MTU is less than the current. This
> > behavior is undesirable when the user space is managing the MTU.
> > Instead a sysctl flag 'accept_ra_mtu' is introduced such that the user
> > space can control whether or not RA provided MTU updates should be
> > applied. The default behavior is unchanged; user space must explicitly
> > set this flag to 0 for RA MTUs to be ignored.
> >
> > Signed-off-by: Harout Hedeshian <harouth@codeaurora.org>
> 
> A really sloppy submission, sorry I can't apply this.
> 
> > +	{ CTL_INT,	NET_IPV6_ACCEPT_RA_MTU,
> 	"accept_ra_mtu" },

Yes, it appears include/uapi/linux/sysctl.h was missed during a rebase. I
will correct this.

> This isn't defined anywhere, you left out some file while creating your
patch.
> 
> kernel/sysctl_binary.c:526:13: error: ?NET_IPV6_ACCEPT_RA_MTU?
> undeclared here (not in a function)
> 
> 
> > -	if (ndopts.nd_opts_mtu) {
> > +	if (ndopts.nd_opts_mtu  && in6_dev->cnf.accept_ra_mtu) {
> 
> Too many spaced before the &&

Hmm. Looks like checkpatch.pl did does not catch this mistake. I only get
one warning about a line being too long:

harouth@harouth-lnx:/local/vg_local/lv_mainline/net_next/net-next$
./scripts/checkpatch.pl
0001-net-ipv6-Add-sysctl-entry-to-disable-MTU-updates-fro.patch
WARNING: line over 80 characters
#74: FILE: kernel/sysctl_binary.c:526:
+       { CTL_INT,      NET_IPV6_ACCEPT_RA_MTU,
"accept_ra_mtu" },

total: 0 errors, 1 warnings, 0 checks, 69 lines checked

0001-net-ipv6-Add-sysctl-entry-to-disable-MTU-updates-fro.patch has style
problems, please review.

I will send an updated patch (v2) in a moment.

V2 patch passes compilation in sysctl_binary.c:
harouth@harouth-lnx:/local/vg_local/lv_mainline/net_next/net-next$ make -j8
ARCH=um
..
  CC      kernel/sysctl.o
  CC      kernel/sysctl_binary.o
..

Thanks,
Harout

--
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux
Foundation Collaborative Project
