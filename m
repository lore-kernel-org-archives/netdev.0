From: Cong Wang <cwang@twopensource.com>
Subject: Re: Fw: [Bug 85091] New: neighbour table overflow is not reported and
 impacts localhost TCP connectivity
Date: Wed, 24 Sep 2014 12:11:36 -0700
Message-ID: <CAHA+R7N=3GZ9sR9G-W4CZtyR8aihDc0DLbtQFifURyyBgC=-5A@mail.gmail.com>
References: <20140924093216.083c77b4@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:33516 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175AbaIXTLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 15:11:37 -0400
Received: by mail-lb0-f180.google.com with SMTP id b12so11164509lbj.39
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 12:11:36 -0700 (PDT)
In-Reply-To: <20140924093216.083c77b4@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 24, 2014 at 9:32 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> Result:
>
> Kernel has to learn the 16k IP/MAC combinations, as soon as gc_thresh3 is hit,
> netperf stalls, no syslog/kernel message indicates the problem.
>
> The only indication are log entries like this:
>
>   "net_ratelimit: 1464 callbacks suppressed"
>
> No other messages are logged.
>

Looks like we have a race condition between we check gc_thresh3
and add the new entry into the table after locking in __neigh_create().
Otherwise the application layer should get EINVAL to stop.
