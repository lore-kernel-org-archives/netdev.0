From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next 3/6] net_sched: cls_bpf: remove faulty use of
 list_for_each_entry_rcu
Date: Wed, 03 Dec 2014 16:15:25 -0500
Message-ID: <547F7D6D.3000709@mojatatu.com>
References: <1417539636-12710-1-git-send-email-jiri@resnulli.us> <1417539636-12710-4-git-send-email-jiri@resnulli.us> <547F0743.4040301@mojatatu.com> <20141203132635.GH1860@nanopsycho.orion> <547F203A.3080208@mojatatu.com> <20141203152051.GK1860@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:46990 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390AbaLCVP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 16:15:27 -0500
Received: by mail-ie0-f173.google.com with SMTP id y20so14466062ier.4
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 13:15:26 -0800 (PST)
In-Reply-To: <20141203152051.GK1860@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/14 10:20, Jiri Pirko wrote:
> Wed, Dec 03, 2014 at 03:37:46PM CET, jhs@mojatatu.com wrote:

>
> Yep, but this is updater, protected by rtnl. _rcu list travelsal variant
> should be used by reader only (classify callback in cls case).
>
> get op is only called from tc_ctl_tfilter which is always called with
> rtnl held.
>


I am not an rcu officionado. So if the control path is doing a non-rcu
get + rcu-del/change (update) then as long as the fastpath is (read)
rcu locking we are fine  and nothing will actually happen until the
fastpath releases and rcu grace period ends, correct?
In which case please accept my:
ACKed-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
