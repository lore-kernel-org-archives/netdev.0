From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [Xen-devel] xen-netback notify DomU to send ARP.
Date: Wed, 09 Jan 2013 13:44:40 +0000
Message-ID: <50ED825802000078000B4113@nat28.tlf.novell.com>
References: <50EC099D.6020407@oracle.com>
 <50EC297A02000078000B3BB5@nat28.tlf.novell.com>
 <1357652541.7989.179.camel@zakaz.uk.xensource.com>
 <50EC3DFD.8060206@oracle.com>
 <1357660834.12649.103.camel@dagon.hellion.org.uk>
 <50ED1EB3.3080605@oracle.com>
 <50ED4F1D02000078000B3F87@nat28.tlf.novell.com>
 <50ED6255.7020006@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <xen-devel@lists.xensource.com>,
	"Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>,
	<netdev@vger.kernel.org>
To: "jianhai luan" <jianhai.luan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat28.tlf.novell.com ([130.57.49.28]:53759 "EHLO
	nat28.tlf.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757436Ab3AINom convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:3:1>);
	Wed, 9 Jan 2013 08:44:42 -0500
In-Reply-To: <50ED6255.7020006@oracle.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> On 09.01.13 at 13:28, jianhai luan <jianhai.luan@oracle.com> wrote:
>>> +	switch (event) {
>>> +	case NETDEV_NOTIFY_PEERS:
>>> +		/* Notify frontend to Send gratuitous ARP */
>>> +		xenbus_switch_state(be->dev, XenbusStateInitialised);
>>> +		xenbus_switch_state(be->dev, );
>> This is the sort of change that clearly isn't acceptable, as I don't
>> think you have ways to check _all_ existing frontends for their
>> compatibility with this. A connected -> connected transition
>> might be acceptable (that was done in the block frontend too, for
>> implementing dynamic resize), but will likely need to be
>> accompanied by a frontend side patch to handle that (which so
>> far should be a no-op).
> The latest xen net-frontent driver have handled the condition. State 
> XenbusStateInitialised will do nothing,
> but change to XenbusStateConnected will trigger 
> netdev_notify_peers(netdev) to send ARP.

Did you read my earlier reply carefully? You still only talk about
(upstream) Linux netfront, but this is not the only (possible)
frontend. You should not invoke state transitions that can -
even if only theoretically - blow up frontends. And afaict the
only thing you can safely assume frontends ought to tolerate
are transitions from Connected to Connected (or more
generally from one state to the same one, but the other
states aren't useful here, except maybe the Reconfigur* ones).

Jan
