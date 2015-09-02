From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next] net: Support ip route get via given table
Date: Wed, 2 Sep 2015 21:38:38 +0200
Message-ID: <20150902193838.GA25648@pox.localdomain>
References: <1441220592-7339-1-git-send-email-dsa@cumulusnetworks.com>
 <20150902191244.GE20527@pox.localdomain>
 <55E74C78.8000409@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:38216 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755159AbbIBTil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 15:38:41 -0400
Received: by wiclp12 with SMTP id lp12so29930902wic.1
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 12:38:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55E74C78.8000409@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/15 at 01:22pm, David Ahern wrote:
> On 9/2/15 1:12 PM, Thomas Graf wrote:
> >On 09/02/15 at 12:03pm, David Ahern wrote:
> >>Add support for 'ip [-6] route get table X' where the user wants to
> >>force the FIB lookup from a given table.
> >>
> >>Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> >
> >Will you use this outside of 'ip route get' as well? If so, how? I'm
> >asking because you propose to add the check and new behaviour to bypass
> >the routing rules to the routing fastpath, wouldn't it be better to
> >handle this in inet_rtm_getroute()?
> >
> 
> The way IPv6 code is structured it seemed more appropriate to pass in a
> table id as part of the flow. I made IPv4 consistent with that approach.

The question is: Are you planning to use the new table_id in flowi
in the actual datapath as well? It seems entirely wrong to add
weight to the fast path for a control plane feature.
