From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3] tc: introduce OpenFlow classifier
Date: Fri, 10 Apr 2015 11:12:03 +0200
Message-ID: <20150410091203.GA2021@nanopsycho.orion>
References: <1428584287-8197-1-git-send-email-jiri@resnulli.us>
 <20150409.173423.2258417584616634411.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:34461 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754161AbbDJJMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 05:12:07 -0400
Received: by widjs5 with SMTP id js5so11682338wid.1
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 02:12:06 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150409.173423.2258417584616634411.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Apr 09, 2015 at 11:34:23PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Thu,  9 Apr 2015 14:58:07 +0200
>
>> This patch introduces OpenFlow-based filter. So far, the very essential
>> packet fields are supported (according to OpenFlow v1.4 spec).
>> 
>> This patch is only the first step. There is a lot of potential performance
>> improvements possible to implement. Also a lot of features are missing
>> now. They will be addressed in follow-up patches.
>> 
>> To the name of this classifier, I believe that "cls_openflow" is pretty
>> accurate. It is actually a OpenFlow classifier.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>
>I'm not so sure what my opinion is about whether we should
>even have an openflow classifier or not (I find major aspects
>of OpenFLOW extremely distasteful, it's basically pushing the
>SDK agenda of several major chip vendors).

Yep, I don't like OpenFlow as well. But anyway, we already have
OpenFlow-based classifier in kernel - in OVS code.

The thing is, why don't have it in tc? It does not cost anything. And
having it, people used to use ovs kernel DP will be able to migrate
easily to tc.

We can loose the name and name this cls_ngflow or something like that if
that helps.

>
>However I am sure that I majorly object to having yet another flow
>parsing engine.  Therefore, at least adjust this code to use our flow
>dissector and datastructures.  Adjust the flow dissector to fit your
>needs, if necessary.

Yep, Thomas already suggested the merge. The thing is, cls_flow uses
linked list for doing lookups. That is not scalable. in cls_openflow I
use rhashtable. Using rhashtable in cls_flow would break the existing
assumption that first inrested filter would be first hit.

So that would lead into major dual code in cls_flow. So I believe that
it is better to do it in separate cls_openflow (do one thing and do it
right).
