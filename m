From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 2/5] dccp: Implement lookup table for
	feature-negotiation information
Date: Mon, 22 Sep 2008 17:45:54 +0200
Message-ID: <20080922154554.GA3521@gerrit.erg.abdn.ac.uk>
References: <20080921.235853.223987556.davem@davemloft.net> <1222068117-13401-1-git-send-email-gerrit@erg.abdn.ac.uk> <1222068117-13401-2-git-send-email-gerrit@erg.abdn.ac.uk> <1222068117-13401-3-git-send-email-gerrit@erg.abdn.ac.uk> <20080922142105.GB16625@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>, davem@davemloft.net,
	dccp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:53867 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752586AbYIVPqF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Sep 2008 11:46:05 -0400
Content-Disposition: inline
In-Reply-To: <20080922142105.GB16625@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > --- a/include/linux/dccp.h
| > +++ b/include/linux/dccp.h
| >  
| > +
| > +static int dccp_feat_default_value(u8 feat_num)
| > +{
| > +	int idx = dccp_feat_index(feat_num);
| > +
| > +	return idx < 0 ? : dccp_feat_table[idx].default_value;
| > +}
| 
| [acme@doppio ~]$ cat dd.c
| #include <stdio.h>
| 
| int main(void)
| {
| 	int idx = -2;
| 
| 	printf("%d\n", idx < 0 ? : 10);
| 	printf("%d\n", idx < 0 ? idx : 10);
| 	return 0;
| }
| [acme@doppio ~]$ ./dd
| 1
| -2
| [acme@doppio ~]$
| 
| Which one do you want? The boolean result as the value to be returned or
| the index if it is < 0?
| 
It is the first value. The test is only there to avoid accessing the
array with an invalid index, which would happen if an unknown `feat_num'
is passed - as for unknown features there is no default value.

| I tried to check on the other 4 patches on this series to check if usage
| clarified if it was correct, but there is no use of
| dccp_feat_default_value() on this 5 patches, perhaps it could be
| deferred to when it actually gets used?
| 
Yes thanks, while I have ensured that all patches are bisectable, a few
functions may be declared where the logical fit was better. I will place
it where it is first used, in the patch entitled "dccp: Registration
routines for changing feature values"

I am waiting before resubmitting - please take a look at patches 3-5 as well.

Gerrit
