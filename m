From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] dccp: Resolve dependencies of features on choice
 of CCID
Date: Mon, 10 Nov 2008 13:17:48 -0800 (PST)
Message-ID: <20081110.131748.152587229.davem@davemloft.net>
References: <1225950014-6337-3-git-send-email-gerrit@erg.abdn.ac.uk>
	<1225950014-6337-4-git-send-email-gerrit@erg.abdn.ac.uk>
	<1225950014-6337-5-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42972
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750772AbYKJVRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2008 16:17:48 -0500
In-Reply-To: <1225950014-6337-5-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu,  6 Nov 2008 06:40:14 +0100

> This provides a missing link in the code chain, as several features implicitly
> depend and/or rely on the choice of CCID. Most notably, this is the Send Ack Vector
> feature, but also Ack Ratio and Send Loss Event Rate (also taken care of).
> 
> For Send Ack Vector, the situation is as follows:
>  * since CCID2 mandates the use of Ack Vectors, there is no point in allowing
>    endpoints which use CCID2 to disable Ack Vector features such a connection;
> 
>  * a peer with a TX CCID of CCID2 will always expect Ack Vectors, and a peer
>    with a RX CCID of CCID2 must always send Ack Vectors (RFC 4341, sec. 4);
> 
>  * for all other CCIDs, the use of (Send) Ack Vector is optional and thus
>    negotiable. However, this implies that the code negotiating the use of Ack
>    Vectors also supports it (i.e. is able to supply and to either parse or
>    ignore received Ack Vectors). Since this is not the case (CCID-3 has no Ack
>    Vector support), the use of Ack Vectors is here disabled, with a comment
>    in the source code.
> 
> An analogous consideration arises for the Send Loss Event Rate feature,
> since the CCID-3 implementation does not support the loss interval options
> of RFC 4342. To make such use explicit, corresponding feature-negotiation
> options are inserted which signal the use of the loss event rate option,
> as it is used by the CCID3 code.
> 
> Lastly, the values of the Ack Ratio feature are matched to the choice of CCID.
> 
> The patch implements this as a function which is called after the user has
> made all other registrations for changing default values of features.
> 
> The table is variable-length, the reserved (and hence for feature-negotiation
> invalid, confirmed by considering section 19.4 of RFC 4340) feature number `0'
> is used to mark the end of the table.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Also applied, thanks.
