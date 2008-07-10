From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 2/2] IPVS: Add genetlink interface implementation
Date: Fri, 11 Jul 2008 01:16:44 +0200
Message-ID: <f4845fc0807101616r1f383e7dx5d85cb3c2dfbed57@mail.gmail.com>
References: <1215616317-11386-1-git-send-email-juliusv@google.com>
	 <1215616317-11386-3-git-send-email-juliusv@google.com>
	 <4874EABC.4000301@trash.net> <20080710112017.GA26952@google.com>
	 <20080710113649.GS20815@postel.suug.ch>
	 <f4845fc0807100533h6867ed00x8975d156b15a866f@mail.gmail.com>
	 <20080710144131.GU20815@postel.suug.ch>
	 <f4845fc0807100813o65dee75bgfc53a395dccf74f6@mail.gmail.com>
	 <20080710211630.GW20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Patrick McHardy" <kaber@trash.net>, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, vbusam@google.com, horms@verge.net.au,
	davem@davemloft.net
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:31643 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985AbYGJXRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 19:17:16 -0400
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id m6ANGjl1011580
	for <netdev@vger.kernel.org>; Fri, 11 Jul 2008 00:16:46 +0100
Received: from yx-out-2324.google.com (yxb8.prod.google.com [10.190.1.72])
	by spaceape11.eur.corp.google.com with ESMTP id m6ANGDXt010112
	for <netdev@vger.kernel.org>; Fri, 11 Jul 2008 00:16:45 +0100
Received: by yx-out-2324.google.com with SMTP id 8so1013891yxb.69
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 16:16:44 -0700 (PDT)
In-Reply-To: <20080710211630.GW20815@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 10, 2008, Thomas Graf wrote:
> Personally I would never use a GET id to send any data at all. My main
> focus is on trying to make message protocols self documenting. If a
> certain message type has multiple meanings depending on the direction
> it will make it harder to understand and harder to debug from a protocol
> standpoint.

Makes sense so far, but:

> The common netlink semantics are
>
>  CMD_OBJ_NEW - create or update objects as described in the message
>               content.

If a single operation just means create _or_ update (NLM_F_EXCL, etc.
flags don't work with genetlink), then ipvsadm would have to query for
an entry first, which is racy and ugly. So I'd like to keep ADD/EDIT
in separate commands. But then I need a different response id (or just
use the ADD id?) for a GET.

>  CMD_OBJ_SET - rarely used, update a static object which doesn't have
>               to be created or added. asme as OBJ_NEW otherwise.

Like in the case of sending the GET_INFO or GET_TIMEOUT replies.

>  CMD_OBJ_DEL - delete object described in the message
>  CMD_OBJ_GET - search for a object as described in the message and
>               send a CMD_OBJ_NEW as reply including the full object.
>
>               with NLM_F_DUMP: iterate over all objects and send a
>               CMD_OBJ_NEW for each object. This request often carries
>               no additional data.

Ok, that makes sense too and is pretty much what I have.

Julius

-- 
Google Switzerland GmbH
