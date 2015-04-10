From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3] tc: introduce OpenFlow classifier
Date: Fri, 10 Apr 2015 14:45:17 +0200
Message-ID: <20150410124517.GC2021@nanopsycho.orion>
References: <1428584287-8197-1-git-send-email-jiri@resnulli.us>
 <20150409.173423.2258417584616634411.davem@davemloft.net>
 <20150410091203.GA2021@nanopsycho.orion>
 <20150410.082359.964457460073432676.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:34445 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932361AbbDJMpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 08:45:20 -0400
Received: by widjs5 with SMTP id js5so15331695wid.1
        for <netdev@vger.kernel.org>; Fri, 10 Apr 2015 05:45:19 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150410.082359.964457460073432676.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Apr 10, 2015 at 02:23:59PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Fri, 10 Apr 2015 11:12:03 +0200
>
>> Thu, Apr 09, 2015 at 11:34:23PM CEST, davem@davemloft.net wrote:
>>>However I am sure that I majorly object to having yet another flow
>>>parsing engine.  Therefore, at least adjust this code to use our flow
>>>dissector and datastructures.  Adjust the flow dissector to fit your
>>>needs, if necessary.
>> 
>> Yep, Thomas already suggested the merge. The thing is, cls_flow uses
>> linked list for doing lookups. That is not scalable. in cls_openflow I
>> use rhashtable. Using rhashtable in cls_flow would break the existing
>> assumption that first inrested filter would be first hit.
>
>I'm talking about using net/core/flow_dissect.c's interfaces instead
>of your by-hand header parsing.  This has nothing to do with cls_flow

Okay. That was misunderstanding. I was thinking about using existing
flow_dissect. There are couple things which I'm scared of:
- there are eventually many fields to be added to dissection function and to
  the structure as well. Not sure how acceptable that would be for
  performance reasons when flow_dissect is used by different users...
- ipv6 addresses are hashed into int. Not sure how to resolve it, maybe to
  have another field for unhashed addresses
