From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 1/5] dccp: Mechanism to resolve CCID dependencies
Date: Tue, 18 Nov 2008 06:03:47 +0100
Message-ID: <20081118050346.GA3846@gerrit.erg.abdn.ac.uk>
References: <20081112063643.GB6405@gerrit.erg.abdn.ac.uk> <1226751079-15019-1-git-send-email-gerrit@erg.abdn.ac.uk> <1226751079-15019-2-git-send-email-gerrit@erg.abdn.ac.uk> <20081116.225040.197479116.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="DocE+STaALJfprDB"
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:50543 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750945AbYKRFDz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2008 00:03:55 -0500
Content-Disposition: inline
In-Reply-To: <20081116.225040.197479116.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--DocE+STaALJfprDB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

| > +	list_for_each_entry(entry, fn_list, node)
| > +		if (entry->feat_num == feat_num && entry->is_local == is_local)
| > +			return entry;
| > +		else if (entry->feat_num > feat_num)
| > +			break;
| 
| Personally, I would have put braces around this basic block.
| 
If it is possible to modify without disturbance, I attach a patch for this and
have changed it in the test tree.

I have checked that making this change does not affect subsequent
patches - it works with either variant.

--DocE+STaALJfprDB
Content-Type: text/x-diff; charset=us-ascii
Content-Description: Missing braces
Content-Disposition: attachment; filename="3.diff"

--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -171,11 +171,12 @@ static struct dccp_feat_entry *dccp_feat
 {
 	struct dccp_feat_entry *entry;
 
-	list_for_each_entry(entry, fn_list, node)
+	list_for_each_entry(entry, fn_list, node) {
 		if (entry->feat_num == feat_num && entry->is_local == is_local)
 			return entry;
 		else if (entry->feat_num > feat_num)
 			break;
+	}
 	return NULL;
 }
 

--DocE+STaALJfprDB--
