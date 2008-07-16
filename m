From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCH 2/2] IPVS: Add genetlink interface implementation
Date: Wed, 16 Jul 2008 15:03:40 +0200
Message-ID: <f4845fc0807160603s57e93d52r2a47b3b63f4e4aa0@mail.gmail.com>
References: <1215616317-11386-1-git-send-email-juliusv@google.com>
	 <4874EABC.4000301@trash.net> <20080710112017.GA26952@google.com>
	 <20080710113649.GS20815@postel.suug.ch>
	 <f4845fc0807100533h6867ed00x8975d156b15a866f@mail.gmail.com>
	 <20080710144131.GU20815@postel.suug.ch>
	 <f4845fc0807100813o65dee75bgfc53a395dccf74f6@mail.gmail.com>
	 <20080710211630.GW20815@postel.suug.ch>
	 <f4845fc0807101616r1f383e7dx5d85cb3c2dfbed57@mail.gmail.com>
	 <20080716121524.GZ20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Patrick McHardy" <kaber@trash.net>, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org, vbusam@google.com, horms@verge.net.au,
	davem@davemloft.net
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:1675 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754840AbYGPNDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 09:03:48 -0400
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id m6GD3gS5018538
	for <netdev@vger.kernel.org>; Wed, 16 Jul 2008 14:03:42 +0100
Received: from rn-out-0910.google.com (rndm61.prod.google.com [10.38.139.61])
	by wpaz17.hot.corp.google.com with ESMTP id m6GD3fQd029217
	for <netdev@vger.kernel.org>; Wed, 16 Jul 2008 06:03:41 -0700
Received: by rn-out-0910.google.com with SMTP id m61so1779493rnd.15
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2008 06:03:41 -0700 (PDT)
In-Reply-To: <20080716121524.GZ20815@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 16, 2008, Thomas Graf wrote:
> * Julius Volz <juliusv@google.com> 2008-07-11 01:16
>> If a single operation just means create _or_ update (NLM_F_EXCL, etc.
>> flags don't work with genetlink), then ipvsadm would have to query for
>> an entry first, which is racy and ugly. So I'd like to keep ADD/EDIT
>> in separate commands. But then I need a different response id (or just
>> use the ADD id?) for a GET.
>
> That's fine, both methods a) adding your own NLM_F_ flags to genetlink
> and b) using separate commands would be straight forward and easy to
> understand.

Great.

> The key point is that a GET or DUMP request should be answered with
> one or more NEW requests. An ADD, SET, or DEL request should be simply
> ACKed or aborted with an error message. Optionally it can trigger a
> notification message which should be either a NEW or DEL request.

Makes sense.

> Using SET to explicitely update an object is fine as well. The reason we
> are not using it in the context of notifications is that listeners can
> appear at any time so the listener may not have been around at the time
> the object was created.

Hm, I like that option most. So if you think it's ok, I will use NEW =
add and SET = edit.

Julius

-- 
Google Switzerland GmbH
