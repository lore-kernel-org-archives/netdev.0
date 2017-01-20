From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next V5] tc: flower: Refactor matching
 flags to be more user friendly
Date: Fri, 20 Jan 2017 10:38:39 -0800
Message-ID: <20170120103839.5a5e1719@xeon-e3>
References: <1484836073-47019-1-git-send-email-paulb@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Simon Horman <simon.horman@netronome.com>
To: Paul Blakey <paulb@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:34593 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753041AbdATSir (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 13:38:47 -0500
Received: by mail-pg0-f51.google.com with SMTP id 14so25526210pgg.1
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 10:38:47 -0800 (PST)
In-Reply-To: <1484836073-47019-1-git-send-email-paulb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Jan 2017 16:27:53 +0200
Paul Blakey <paulb@mellanox.com> wrote:

> Instead of "magic numbers" we can now specify each flag
> by name. Prefix of "no"  (e.g nofrag) unsets the flag,
> otherwise it wil be set.
> 
> Example:
>     # add a flower filter that will drop fragmented packets
>     tc filter add dev ens4f0 protocol ip parent ffff: \
>             flower \
>             src_mac e4:1d:2d:fd:8b:01 \
>             dst_mac e4:1d:2d:fd:8b:02 \
>             indev ens4f0 \
>             ip_flags frag \
>     action drop
> 
>     # add a flower filter that will drop non-fragmented packets
>     tc filter add dev ens4f0 protocol ip parent ffff: \
>             flower \
>             src_mac e4:1d:2d:fd:8b:01 \
>             dst_mac e4:1d:2d:fd:8b:02 \
>             indev ens4f0 \
>             ip_flags nofrag \
>     action drop
> 
> Fixes: 22a8f019891c ('tc: flower: support matching flags')
> Signed-off-by: Paul Blakey <paulb@mellanox.com>
> Reviewed-by: Roi Dayan <roid@mellanox.com>
> ---
> 
> Hi,
> Added a framework to add new flags more easily, such 
> as the upcoming tcp_flags (see kernel cls_flower), and other ip_flags.
> 
> Thanks,
>      Paul.
> 
> 
> Changelog:
> 
> v5:
> Fixed wrong use of strtok to skip old prefix.
> 
> v4:
> Changed prefix in manpage as well.
> 
> v3:
> Changed prefix to "no" instead of "no_".
> 
> v2:
> Changed delimiter to "/" to avoid shell pipe errors.
> 
> 
>  man/man8/tc-flower.8 |  12 +++++-
>  tc/f_flower.c        | 117 ++++++++++++++++++++++++++++++++++++++++-----------
>  2 files changed, 102 insertions(+), 27 deletions(-)
> 

Applied to net-next (defuzzed)
