From: Meelis Roos <mroos@linux.ee>
Subject: Re: Turn nfmark into generic mark
Date: Thu, 9 Nov 2006 15:03:59 +0200 (EET)
Message-ID: <Pine.SOC.4.61.0611091450390.19460@math.ut.ee>
References: <20061109113245.439512828@lsx.localdomain>
 <20061109123234.EC7FC1434F@rhn.tartu-labor> <20061109124548.GA8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from math.ut.ee ([193.40.36.2]:52124 "EHLO math.ut.ee")
	by vger.kernel.org with ESMTP id S965978AbWKINEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Nov 2006 08:04:04 -0500
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061109124548.GA8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The mark is already a bitfield, you may dividide it into separate
> marks with the exception of routes which do not yet support a
> mask.

Just checked, now that we have --and-mask and --or-mask, this is much 
better than before.

The bitmask is OK when up to 32 marks are needed (like, for 
classification). But a common setup is NAT+QoS that first hides the src 
IP and then has to do QoS and mark is the only usable carrier of this 
information. So the mark value needs to carry both classification info 
and IP address info and here things become very limited. Though using 
say 8 bits for host should be usually enough...

Maybe just add original src and/ord DST for carrying this information 
through SNAT/DNAT? Or is it too much bloat for carrying around?

-- 
Meelis Roos (mroos@linux.ee)
