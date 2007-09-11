From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH][2/2] Add ICMPMsgStats MIB (RFC 4293)
Date: Tue, 11 Sep 2007 08:21:54 -0700
Message-ID: <OFB359CEB3.1D9E338E-ON88257353.00529BF9-88257353.00545412@us.ibm.com>
References: <20070911.175053.104206872.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, yoshfuji@linux-ipv6.org
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:42885 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754117AbXIKPWT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 11:22:19 -0400
In-Reply-To: <20070911.175053.104206872.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yoshifuji Hideaki <yoshfuji@linux-ipv6.org> wrote on 09/11/2007 01:50:53 
AM:

> Dave, we've been supporting per-interface stats for IPv6, and
> you seem to remove them.  Please keep them.  Thank you.

        The reason I didn't for ICMPMsgStats is the size. The RFC requires
in & out counters for all types, whether or not they are known by the OS,
so that's 512 stats.

Because the MIB variables in the existing infrastructure are not 
dynamically
allocated, that's:

512 * numInterfaces * numCPUs * 2protos

That seems like a lot of mostly-zero memory. Changing them to be run-time
allocated (and re-allocated when new types are seen) is another 
alternative,
but more significant changes.

"Memory is Cheap."
        -- Doug Comer

So maybe it's not so bad -- I'll roll another per-interface version
to see.

                                                        +-DLS

