From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 2/5] dccp: Implement lookup table for
	feature-negotiation information
Date: Wed, 24 Sep 2008 06:41:20 +0200
Message-ID: <20080924044120.GA4944@gerrit.erg.abdn.ac.uk>
References: <20080921.235853.223987556.davem@davemloft.net> <1222068117-13401-1-git-send-email-gerrit@erg.abdn.ac.uk> <1222068117-13401-2-git-send-email-gerrit@erg.abdn.ac.uk> <1222068117-13401-3-git-send-email-gerrit@erg.abdn.ac.uk> <20080922142105.GB16625@ghostprotocols.net> <20080922154554.GA3521@gerrit.erg.abdn.ac.uk> <20080922170013.GF16625@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Arnaldo Carvalho de Melo <acme@redhat.com>, davem@davemloft.net,
	dccp@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:38179 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750884AbYIXEmI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 00:42:08 -0400
Content-Disposition: inline
In-Reply-To: <20080922170013.GF16625@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > | > --- a/include/linux/dccp.h
| > | > +++ b/include/linux/dccp.h
| > | >  
| > | > +
| > | > +static int dccp_feat_default_value(u8 feat_num)
| > | > +{
| > | > +	int idx = dccp_feat_index(feat_num);
| > | > +
| > | > +	return idx < 0 ? : dccp_feat_table[idx].default_value;
| > | > +}
<snip>
| > | 
| > It is the first value. The test is only there to avoid accessing the
| > array with an invalid index, which would happen if an unknown `feat_num'
| > is passed - as for unknown features there is no default value.
| 
| The above explanation would be good to have as a comment, as it was not
| so obvious from a first sight. I think that even having it explicit
| would be clearer:
| 
| return idx < 0 ? 1 : dccp_feat_table[idx].default_value;
| 
| But then, if an unknown feat num is passed shouldn't the code bailout in
| some other fashion than returning the result of a boolean expression and
| not accessing the defaults table?
| 
Yes thank you. It is necessary to check this, since only in the current
state of code the use of the function is consistent.  If the code gets
changed later on then there will be no warning.

I have worked on this function yesterday evening with regard to above
feedback. If you could either check again when the patch is submitted
later, or have a look at the online version in the test tree on
http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=dccp_exp.git;a=commitdiff;h=b0708121bfeb309db88e1b3a97cf851069bcafe1

