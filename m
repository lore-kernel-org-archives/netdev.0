From: Eric Paris <eparis@parisplace.org>
Subject: Re: [PATCH]: Add security check before flushing SAD/SPD
Date: Mon, 26 Mar 2007 16:34:11 -0400
Message-ID: <1174941251.17953.4.camel@localhost.localdomain>
References: <200703261939.l2QJd7X7012809@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, jmorris@namei.org,
	selinux@tycho.nsa.gov
To: Joy Latten <latten@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49410 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751024AbXCZUeb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Mar 2007 16:34:31 -0400
In-Reply-To: <200703261939.l2QJd7X7012809@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-03-26 at 13:39 -0600, Joy Latten wrote:
> +			if ((err = security_xfrm_policy_delete(pol)) != 0) {
> +				xfrm_audit_log(audit_info->loginuid,
> +					       audit_info->secid,
> +					       AUDIT_MAC_IPSEC_DELSPD,
> +					       err ? 0 : 1, pol, NULL);
> +				return err;

In all of the denial log statements you keep the "err ? 0 : 1" which are
common among audit, but in this patch we always know that err is 1. Is
it worth simplifying this down to just a 0 in the all of the
xfrm_audit_log calls?

-Eric

