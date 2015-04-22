From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH v2 3/3] mpls: Prevent use of implicit NULL label as outgoing label
Date: Wed, 22 Apr 2015 11:32:47 -0500
Message-ID: <87sibsktsg.fsf@x220.int.ebiederm.org>
References: <1429648467-8449-1-git-send-email-rshearma@brocade.com>
	<1429697679-13767-1-git-send-email-rshearma@brocade.com>
	<1429697679-13767-4-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:33446 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965499AbbDVQhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 12:37:04 -0400
In-Reply-To: <1429697679-13767-4-git-send-email-rshearma@brocade.com> (Robert
	Shearman's message of "Wed, 22 Apr 2015 11:14:39 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Shearman <rshearma@brocade.com> writes:

> The reserved implicit-NULL label isn't allowed to appear in the label
> stack for packets, so make it an error for the control plane to
> specify it as an outgoing label.

Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>

>
> Suggested-by: "Eric W. Biederman" <ebiederm@xmission.com>
> Signed-off-by: Robert Shearman <rshearma@brocade.com>
> ---
>  net/mpls/af_mpls.c | 9 +++++++++
>  1 file changed, 9 insertions(+)
>
> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index 9fdd94cba83e..954810c76a86 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
> @@ -646,6 +646,15 @@ int nla_get_labels(const struct nlattr *nla,
>  		if ((dec.bos != bos) || dec.ttl || dec.tc)
>  			return -EINVAL;
>  
> +		switch (dec.label) {
> +		case LABEL_IMPLICIT_NULL:
> +			/* RFC3032: This is a label that an LSR may
> +			 * assign and distribute, but which never
> +			 * actually appears in the encapsulation.
> +			 */
> +			return -EINVAL;
> +		}
> +
>  		label[i] = dec.label;
>  	}
>  	*labels = nla_labels;
