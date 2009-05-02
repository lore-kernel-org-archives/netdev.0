From: jamal <hadi@cyberus.ca>
Subject: RE: [RFC PATCH] qos: Limit a filter's priority to a 16 bit value
Date: Fri, 01 May 2009 21:52:06 -0400
Message-ID: <1241229126.7162.5.camel@dogo.mojatatu.com>
References: <20090501184242.12714.2663.stgit@fritz>
	 <20090501.155155.58484825.davem@davemloft.net>
	 <273D38FBE7C6FE46A1689FCD014A0B8B495C016A@azsmsx505.amr.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Love, Robert W" <robert.w.love@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f196.google.com ([209.85.221.196]:54864 "EHLO
	mail-qy0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752610AbZEBBwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 21:52:37 -0400
Received: by qyk34 with SMTP id 34so3900020qyk.33
        for <netdev@vger.kernel.org>; Fri, 01 May 2009 18:52:32 -0700 (PDT)
In-Reply-To: <273D38FBE7C6FE46A1689FCD014A0B8B495C016A@azsmsx505.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-05-01 at 16:30 -0700, Love, Robert W wrote:

> I should be more clear by saying that this should only
> fail with filter priorities assigned by the kernel.
> I think if the user passes down the priority when
> creating the filter it should always be 16bits and it's
> fine.
> 
> However, when the kernel is assigning priorities, the
> first assigned priority for a filter is 0xC0000000,
> the second is "the lowest priority - 1" so 0xBFFFFFFF.
> 
> It will assign this value in tcf_auto_prio() which will
> directly assign the 32bit value to to tp->prio with-
> 
> tp->prio = nprio ? : tcf_auto_prio(*back);

I think the above should read:
tp->prio = nprio ? : TC_H_MAJ(tcf_auto_prio(*back));

More importantly however, you should _never_ specify
a filter you intend to delete individually without specifying 
its priority.
Common practise in scripts is to just delete the root 
qdisc or class to delete all filters.

cheers,
jamal

