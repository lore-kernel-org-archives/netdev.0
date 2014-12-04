From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [patch net-next v4 8/9] net: move vlan pop/push functions into
 common code
Date: Thu, 4 Dec 2014 17:57:41 +0100
Message-ID: <20141204175741.64aaa190@griffin>
References: <1416402303-25341-1-git-send-email-jiri@resnulli.us>
	<1416402303-25341-9-git-send-email-jiri@resnulli.us>
	<CALnjE+pM=D=OEnkuC3h8iQHzF3Qc33CNA7CMgB2=H0hMboxiKQ@mail.gmail.com>
	<20141121180553.GA2251@nanopsycho.orion>
	<CALnjE+p3PtaOz7Ujp7KDK0-=giP-kzEDDDvw8=GCjJdcECYJEA@mail.gmail.com>
	<20141121202933.2970b7ea@griffin>
	<CALnjE+r0U9-cTZYZh=qzWoztfV_TNFoB762CBcDjUj1Z5oDYag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Daniel Borkmann <dborkman@redhat.com>, mst@redhat.com,
	fw@strlen.de, Paul.Durrant@citrix.com, Thomas Graf <tgraf@suug.ch>,
	Cong Wang <cwang@twopensource.com>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49157 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932313AbaLDQ6X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2014 11:58:23 -0500
In-Reply-To: <CALnjE+r0U9-cTZYZh=qzWoztfV_TNFoB762CBcDjUj1Z5oDYag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 3 Dec 2014 16:33:57 -0800, Pravin Shelar wrote:
> OVS correctly sets mac header length in case of vlan header. Can you
> give me OVS test case to reproduce this issue?

Set up ovs bridge with two ports, one of them tagged. Receive a packet
with two vlan headers (the first vlan tag corresponding to the second
port) on the untagged port.

Tried it just now with the latest net-next with printks added to
__skb_vlan_pop, __skb_vlan_pop is called twice for each packet, the
second invocation has the pointers set in the way I described.

 Jiri

-- 
Jiri Benc
