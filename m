From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: Using skb->mark outside netfilter
Date: Tue, 07 May 2013 09:04:18 -0400
Message-ID: <5188FBD2.5090200@mojatatu.com>
References: <1365442863-32394-1-git-send-email-antonio@open-mesh.com> <20130506184817.GA2729@open-mesh.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Antonio Quartulli <antonio@open-mesh.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:46604 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932151Ab3EGNEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 09:04:20 -0400
Received: by mail-ie0-f176.google.com with SMTP id at1so860429iec.21
        for <netdev@vger.kernel.org>; Tue, 07 May 2013 06:04:20 -0700 (PDT)
In-Reply-To: <20130506184817.GA2729@open-mesh.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-05-06 02:48 PM, Antonio Quartulli wrote:

>
> Now to extend this mechanism network-wide (remember that the use case is a Layer2
> mesh network set up with batman-adv) I'm going to introduce a mechanism in
> batman-adv itself which is supposed to read and write the skb->mark field
> so that the value contained when the packet is leaving one end can be restored
> later on the other end of the intra-mesh communication (only if it matches a pre
> configured one).
> This would allow the remote node to perform the same filtering
> operation as if the packet was locally generated.
>

Nice idea.
How do you encode the mark in the batman header?

> Now my question is (I think David is the one who should probably decide here):
> is batman-adv allowed to touch the mark field of the sk_buff structure? Or is it
> reserved for netfilter purposes only?
>


Ok, let me see if i can come up with a definition for mark:
"A general purpose 32 bit tag used in the network subsystem
to carry metadata with global implications across network
sub-subsystem. As an example, a driver could mark on incoming
packet to be used by the ingress tc classifier-action sub-subsystem,
netfilter, ipsec all to execute provisioned policies. Since marks
have global implications, any changes in the datapath flow would
have repurcassions at each sub-subsytem level the packet flows to
next.
The mark could also be used to direct packets to matching socket
apps (eg tcp applications) which have registered for it ......
... more text here on how the mark is used for egress ...
"

So please, use it.

> In my opinion this field (which survives whatever path the skb follows) is the
> best option for this task as it allows batman-adv to "communicate" with
> tc and possibly netfilter itself (if in the future users would like to perform
> more complicated operations).
>

Yes. Also apps which setsockopt to it etc

>
> To clarify the idea, here you have an ascii art representing a possible setup
> and how the mark will be read and set:

Looks sane to me.

cheers,
jamal
