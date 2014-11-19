From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [patch net-next v3 8/9] net: move vlan pop/push functions into
 common code
Date: Wed, 19 Nov 2014 14:03:57 +0100
Message-ID: <20141119140357.5f9d0594@griffin>
References: <1416346664-9290-1-git-send-email-jiri@resnulli.us>
	<1416346664-9290-9-git-send-email-jiri@resnulli.us>
	<CALnjE+rJEtyL-QDrp0x+N_pCxDuR6soHkaY-OrswWrdZwfE2sQ@mail.gmail.com>
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
Received: from mx1.redhat.com ([209.132.183.28]:60199 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752065AbaKSNEt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2014 08:04:49 -0500
In-Reply-To: <CALnjE+rJEtyL-QDrp0x+N_pCxDuR6soHkaY-OrswWrdZwfE2sQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Nov 2014 00:06:19 -0800, Pravin Shelar wrote:
> skb_reset_mac_len() sets length according to ethernet and network
> offsets, but mpls expects mac-length to be offset to mpls header (ref.
> skb_mpls_header()). Therefore rather than reset we need to subtract
> VLAN_HLEN from mac_len. Same goes for vlan-push(), we can add
> VLAN_HLEN.

Subtracting VLAN_HLEN from mac_len would break the common vlan cases,
where skb->protocol is ETH_P_8021Q and skb->mac_len is 14 on input to
__skb_vlan_pop. After __skb_vlan_pop pops the vlan header, it changes
skb->protocol to the protocol of the actual frame and has to leave
skb->mac_len at 14.

You'll need something more sophisticated to support MPLS here, I'm
afraid.

 Jiri

-- 
Jiri Benc
