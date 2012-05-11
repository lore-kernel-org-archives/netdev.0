From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH v4 1/2] vhost-net: fix handle_rx buffer size
Date: Fri, 11 May 2012 16:05:53 -0700
Message-ID: <m1zk9ez5bi.fsf@fess.ebiederm.org>
References: <1336121724-31902-1-git-send-email-basil.gor@gmail.com>
	<20120508192732.GA28536@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Basil Gor <basil.gor@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:37334 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751556Ab2EKXBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 19:01:35 -0400
In-Reply-To: <20120508192732.GA28536@redhat.com> (Michael S. Tsirkin's message
	of "Tue, 8 May 2012 22:27:33 +0300")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Michael S. Tsirkin" <mst@redhat.com> writes:

> On Fri, May 04, 2012 at 12:55:23PM +0400, Basil Gor wrote:
>> Take vlan header length into account, when vlan id is stored as
>> vlan_tci. Otherwise tagged packets comming from macvtap will be
>> truncated.
>> 
>> Signed-off-by: Basil Gor <basil.gor@gmail.com>
>
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
>
> This doesn't fix packet socket backends but that can be
> handled separately later.

Yes that seems good enough.

Let me recommend just taking the packet out of the socket queue
instead of calling the recvmsg method.  Since vhost/net.c is
already munging with the queue directly that should make
it easy to avoid the peculiarities of pf_packet sockets
for reporting vlan information.

Eric
