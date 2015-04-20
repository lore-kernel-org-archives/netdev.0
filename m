From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH] neighbour.c: Avoid GC directly after state change
Date: Mon, 20 Apr 2015 11:33:36 +0900
Message-ID: <55346580.6060801@miraclelinux.com>
References: <1426107673-45049-1-git-send-email-netdev@emagii.com> <20150312.142621.1128728353472907283.davem@davemloft.net> <5527892D.4020608@ericsson.com> <552F45AA.6010906@miraclelinux.com> <5530BE40.1000504@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, netdev@vger.kernel.org
To: Ulf Samuelsson <ulf.samuelsson@ericsson.com>, netdev@emagii.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og112.obsmtp.com ([64.18.2.177]:36967 "HELO
	exprod7og112.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752343AbbDTCdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Apr 2015 22:33:41 -0400
Received: by mail-pd0-f174.google.com with SMTP id qa5so192255409pdb.1
        for <netdev@vger.kernel.org>; Sun, 19 Apr 2015 19:33:40 -0700 (PDT)
In-Reply-To: <5530BE40.1000504@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Ulf Samuelsson wrote:
>>  From RFC2461:
>>
>> |      REACHABLE   Roughly speaking, the neighbor is known to have been
>> |                  reachable recently (within tens of seconds ago).
>> :
>> |      STALE       The neighbor is no longer known to be reachable but
>> |                  until traffic is sent to the neighbor, no attempt
>> |                  should be made to verify its reachability.
>> |      DELAY       The neighbor is no longer known to be reachable, and
>> |                  traffic has recently been sent to the neighbor.
>> |                  Rather than probe the neighbor immediately, however,
>> |                  delay sending probes for a short while in order to
>> |                  give upper layer protocols a chance to provide
>> |                  reachability confirmation.
>>
>>
> 
> It is all depending on the meaning of the word "recently".
> You imply, that if timeouts have been triggered, then it is no longer "recent",
> but that is not the only interpretation, it is up to the implementer to decide
> what is "recently".

That quoted text is just a "brief" description.  The document has detailed
state machine.


> Therefore, if a timeout occurs due to no traffic, they must be probed before
> they are garbage collected.

It is what we do in PROBE state.


> If this is not acceptable, how do you propose to solve the problem that you cannot
> make remote units inaccessible for more than a fraction of a second?

How many neighbors do you want to maintain?
I guess you have to increase the number of gc_thresh1.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
