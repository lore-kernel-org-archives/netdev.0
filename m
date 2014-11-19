From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [patch net-next v3 8/9] net: move vlan pop/push functions into
 common code
Date: Wed, 19 Nov 2014 12:32:07 -0800
Message-ID: <CALnjE+pFp+3gBgufV9ySewCDpuLQvVqxWT-7xM3oshtpuxaKuQ@mail.gmail.com>
References: <1416346664-9290-1-git-send-email-jiri@resnulli.us>
	<1416346664-9290-9-git-send-email-jiri@resnulli.us>
	<CALnjE+rJEtyL-QDrp0x+N_pCxDuR6soHkaY-OrswWrdZwfE2sQ@mail.gmail.com>
	<20141119140357.5f9d0594@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Daniel Borkmann <dborkman@redhat.com>, mst@redhat.com,
	fw@strlen.de, Paul.Durrant@citrix.com, Thomas Graf <tgraf@suug.ch>,
	Cong Wang <cwang@twopensource.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog131.obsmtp.com ([74.125.149.247]:32965 "HELO
	na3sys009aog131.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756208AbaKSUcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 15:32:08 -0500
Received: by mail-ie0-f172.google.com with SMTP id ar1so1369403iec.17
        for <netdev@vger.kernel.org>; Wed, 19 Nov 2014 12:32:07 -0800 (PST)
In-Reply-To: <20141119140357.5f9d0594@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 19, 2014 at 5:03 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Wed, 19 Nov 2014 00:06:19 -0800, Pravin Shelar wrote:
>> skb_reset_mac_len() sets length according to ethernet and network
>> offsets, but mpls expects mac-length to be offset to mpls header (ref.
>> skb_mpls_header()). Therefore rather than reset we need to subtract
>> VLAN_HLEN from mac_len. Same goes for vlan-push(), we can add
>> VLAN_HLEN.
>
> Subtracting VLAN_HLEN from mac_len would break the common vlan cases,
> where skb->protocol is ETH_P_8021Q and skb->mac_len is 14 on input to
> __skb_vlan_pop. After __skb_vlan_pop pops the vlan header, it changes
> skb->protocol to the protocol of the actual frame and has to leave
> skb->mac_len at 14.
>

MPLS API depends on mac-length to point to start of MPLS. OVS takes
care of this by setting mac-length of every packet it process
accordingly.  If that is not in common path then we can not move this
API to common path, Since that will break OVS MPLS action.


> You'll need something more sophisticated to support MPLS here, I'm
> afraid.
>
>  Jiri
>
> --
> Jiri Benc
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
