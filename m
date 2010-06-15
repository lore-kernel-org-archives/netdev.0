From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH v6] netfilter: Xtables: idletimer target implementation
Date: Tue, 15 Jun 2010 15:05:13 +0200
Message-ID: <4C177A89.7060301@trash.net>
References: <1276605926-11598-1-git-send-email-luciano.coelho@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	jengelh@medozas.de, Timo Teras <timo.teras@iki.fi>
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39858 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755152Ab0FONFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 09:05:16 -0400
In-Reply-To: <1276605926-11598-1-git-send-email-luciano.coelho@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Luciano Coelho wrote:
> This patch implements an idletimer Xtables target that can be used to
> identify when interfaces have been idle for a certain period of time.
>
> Timers are identified by labels and are created when a rule is set with a new
> label.  The rules also take a timeout value (in seconds) as an option.  If
> more than one rule uses the same timer label, the timer will be restarted
> whenever any of the rules get a hit.
>
> One entry for each timer is created in sysfs.  This attribute contains the
> timer remaining for the timer to expire.  The attributes are located under
> the xt_idletimer class:
>
> /sys/class/xt_idletimer/timers/<label>
>
> When the timer expires, the target module sends a sysfs notification to the
> userspace, which can then decide what to do (eg. disconnect to save power).
>   

Applied with a minor compiler warning fix:

  CC [M]  net/netfilter/xt_IDLETIMER.o
net/netfilter/xt_IDLETIMER.c:255: warning: initialization from 
incompatible pointer type

The struct xt_tgchk_param argument to ->checkentry is const.
