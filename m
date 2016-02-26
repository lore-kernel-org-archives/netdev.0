From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next PATCH v3 3/3] net: sched: cls_u32 add bit to specify
 software only rules
Date: Fri, 26 Feb 2016 16:58:12 +0100
Message-ID: <20160226155812.GF2158@nanopsycho.orion>
References: <20160226154858.5338.90569.stgit@john-Precision-Tower-5810>
 <20160226155439.5338.34813.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@iogearbox.net, simon.horman@netronome.com,
	netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net, jhs@mojatatu.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35880 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753241AbcBZP6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 10:58:16 -0500
Received: by mail-wm0-f65.google.com with SMTP id a4so9772707wme.3
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 07:58:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160226155439.5338.34813.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Feb 26, 2016 at 04:54:39PM CET, john.fastabend@gmail.com wrote:
>In the initial implementation the only way to stop a rule from being
>inserted into the hardware table was via the device feature flag.
>However this doesn't work well when working on an end host system
>where packets are expect to hit both the hardware and software
>datapaths.
>
>For example we can imagine a rule that will match an IP address and
>increment a field. If we install this rule in both hardware and
>software we may increment the field twice. To date we have only
>added support for the drop action so we have been able to ignore
>these cases. But as we extend the action support we will hit this
>example plus more such cases. Arguably these are not even corner
>cases in many working systems these cases will be common.
>
>To avoid forcing the driver to always abort (i.e. the above example)
>this patch adds a flag to add a rule in software only. A careful
>user can use this flag to build software and hardware datapaths
>that work together. One example we have found particularly useful
>is to use hardware resources to set the skb->mark on the skb when
>the match may be expensive to run in software but a mark lookup
>in a hash table is cheap. The idea here is hardware can do in one
>lookup what the u32 classifier may need to traverse multiple lists
>and hash tables to compute. The flag is only passed down on inserts.
>On deletion to avoid stale references in hardware we always try
>to remove a rule if it exists.
>
>The flags field is part of the classifier specific options. Although
>it is tempting to lift this into the generic structure doing this
>proves difficult do to how the tc netlink attributes are implemented
>along with how the dump/change routines are called. There is also
>precedence for putting seemingly generic pieces in the specific
>classifier options such as TCA_U32_POLICE, TCA_U32_ACT, etc. So
>although not ideal I've left FLAGS in the u32 options as well as it
>simplifies the code greatly and user space has already learned how
>to manage these bits ala 'tc' tool.
>
>Another thing if trying to update a rule we require the flags to
>be unchanged. This is to force user space, software u32 and
>the hardware u32 to keep in sync. Thanks to Simon Horman for
>catching this case.
>
>Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
