From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Centralizing support for TCAM?
Date: Fri, 2 Sep 2016 10:18:39 -0700
Message-ID: <b8323295-e3eb-48ca-7c82-ff40d222a743@gmail.com>
References: <57d4a2db-ca3b-909a-073a-52ecceb428f2@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, idosh@mellanox.com, john.fastabend@intel.com,
        ast@kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        ecree@solarflare.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:35767 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932236AbcIBRSm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 13:18:42 -0400
Received: by mail-pa0-f67.google.com with SMTP id cf3so5779208pad.2
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 10:18:41 -0700 (PDT)
In-Reply-To: <57d4a2db-ca3b-909a-073a-52ecceb428f2@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

(apologies for the long CC list and the fact that I can't type correctly
email addresses)

While working on adding support for the Broadcom Ethernet switches
Compact Field Processor (which is essentially a TCAM,
action/policer/rate meter RAMs, 256 entries), I started working with the
ethtool::rxnfc API which is actually kind of nice in that it fits nicely
with my use simple case of being able to insert rules at a given or
driver selected location and has a pretty good flow representation for
common things you may match: TCP/UDP v4/v6 (not so much for non-IP, or
L2 stuff though you can use the extension flow representation). It lacks
support for more complex actions other than redirect to a particular
port/queue.

Now ethtool::rxnfc is one possible user, but tc and netfiler also are,
more powerful and extensible, but since this is a resource constrained
piece of hardware, and it would suck for people to have to implement
these 3 APIs if we could come up with a central one that satisfies the
superset offered by tc + netfilter. We can surely imagine an use case we
centralize the whole matching + action into a Domain Specific Language
that we compiled into eBPF and then translate into whatever the HW
understands, although that raises the question of where do we put the
translation tool in user space or kernel space.

So what's everybody's take on this?

Thanks!
-- 
Florian
