From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 2/5] dccp: Implement lookup table for
	feature-negotiation information
Date: Mon, 22 Sep 2008 11:21:05 -0300
Message-ID: <20080922142105.GB16625@ghostprotocols.net>
References: <20080921.235853.223987556.davem@davemloft.net> <1222068117-13401-1-git-send-email-gerrit@erg.abdn.ac.uk> <1222068117-13401-2-git-send-email-gerrit@erg.abdn.ac.uk> <1222068117-13401-3-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, dccp@vger.kernel.org, netdev@vger.kernel.org
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48866 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752024AbYIVOaE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2008 10:30:04 -0400
Content-Disposition: inline
In-Reply-To: <1222068117-13401-3-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Sep 22, 2008 at 09:21:54AM +0200, Gerrit Renker escreveu:
> A lookup table for feature-negotiation information, extracted from RFC 4340/42,
> is provided by this patch. All currently known features can be found in this
> table, along with their feature location, their default value, and type.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> ---
>  include/linux/dccp.h |    9 ++--
>  net/dccp/feat.c      |  115 ++++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 120 insertions(+), 4 deletions(-)
> 
> --- a/include/linux/dccp.h
> +++ b/include/linux/dccp.h
>  
> +
> +static int dccp_feat_default_value(u8 feat_num)
> +{
> +	int idx = dccp_feat_index(feat_num);
> +
> +	return idx < 0 ? : dccp_feat_table[idx].default_value;
> +}

[acme@doppio ~]$ cat dd.c
#include <stdio.h>

int main(void)
{
	int idx = -2;

	printf("%d\n", idx < 0 ? : 10);
	printf("%d\n", idx < 0 ? idx : 10);
	return 0;
}
[acme@doppio ~]$ ./dd
1
-2
[acme@doppio ~]$

Which one do you want? The boolean result as the value to be returned or
the index if it is < 0?

I tried to check on the other 4 patches on this series to check if usage
clarified if it was correct, but there is no use of
dccp_feat_default_value() on this 5 patches, perhaps it could be
deferred to when it actually gets used?

- Arnaldo
