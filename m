From: Andrew Grover <andy.grover@gmail.com>
Subject: Re: [PATCH 03/21] RDS: Congestion-handling code
Date: Tue, 27 Jan 2009 11:10:49 -0800
Message-ID: <c0a09e5c0901271110v196930f1i26bdd0d00403fd76@mail.gmail.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
	 <1233022678-9259-4-git-send-email-andy.grover@oracle.com>
	 <20090127131049.GE2646@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andy Grover <andy.grover@oracle.com>, rdreier@cisco.com,
	rds-devel@oss.oracle.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:38977 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755303AbZA0TKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 14:10:49 -0500
Received: by wf-out-1314.google.com with SMTP id 27so7629403wfd.4
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2009 11:10:49 -0800 (PST)
In-Reply-To: <20090127131049.GE2646@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2009 at 5:10 AM, Evgeniy Polyakov <zbr@ioremap.net> wrote:
> On Mon, Jan 26, 2009 at 06:17:40PM -0800, Andy Grover (andy.grover@oracle.com) wrote:
>> +/*
>> + * Yes, a global lock.  It's used so infrequently that it's worth keeping it
>> + * global to simplify the locking.  It's only used in the following
>> + * circumstances:
>> + *
>> + *  - on connection buildup to associate a conn with its maps
>
> Is this a rare condition? Is this protocol only intended for the
> long-living connections and is not suitable for the cases when lots of
> them are created and teared down quickly?

Connections are long-lived. Imagine a cluster. RDS multiplexes all
sockets' datagrams between 2 hosts over a single transport-layer
connection, so if a node sends ONE datagram to another, an IB
connection is set up and sticks around indefinitely.

Regards -- Andy
