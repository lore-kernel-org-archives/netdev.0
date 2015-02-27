From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Named sockets WAS(Re: Flows! Offload them.
Date: Fri, 27 Feb 2015 08:15:47 -0500
Message-ID: <54F06E03.7050303@mojatatu.com>
References: <20150226074214.GF2074@nanopsycho.orion> <20150226112252.GF9840@oracle.com> <20150226113942.GC1973@nanopsycho.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, jpettit@nicira.com,
	joestringer@nicira.com, john.r.fastabend@intel.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, simon.horman@netronome.com,
	shrijeet@gmail.com, gospo@cumulusnetworks.com, bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:37275 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538AbbB0NPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 08:15:55 -0500
Received: by igbhn18 with SMTP id hn18so132195igb.2
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 05:15:54 -0800 (PST)
In-Reply-To: <20150226113942.GC1973@nanopsycho.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Sorry - catching up with the discussion; so many parallel topics
buried..
I just wanna put my TU ("thumbs up", yes I didnt want to do the
pedestrian +1) for the named socket concept. With the explosion of
in-kernel sockets all which intend to do host protocol processing
this would be a very nice abstraction to have.
But i do believe this could also be useful for user space redirecting;
we already have very scalable socket code interfacing which could be
taken advantage of.

cheers,
jamal

On 02/26/15 06:39, Jiri Pirko wrote:
> Thu, Feb 26, 2015 at 12:22:52PM CET, sowmini.varadhan@oracle.com wrote:
>> On (02/26/15 08:42), Jiri Pirko wrote:
>>> 6) implement "named sockets" (working name) and implement TC support for that
>>>      -ingress qdisc attach, act_mirred target
>>> 7) allow tunnels (VXLAN, Geneve, GRE) to be created as named sockets
>>
>> Can you elaborate a bit on the above two?
>
> Sure. If you look into net/openvswitch/vport-vxlan.c for example, there
> is a socket created by vxlan_sock_add. vxlan_rcv is called on rx and
> vxlan_xmit_skb to xmit.
>
> What I have on mind is to allow to create tunnels using "ip" but not as
> a device but rather just as a wrapper of these functions (and others alike).
>
> To identify the instance we name it (OVS has it identified and vport).
> After that, tc could allow to attach ingress qdisk not only to a device,
> but to this named socket as well. Similary with tc action mirred, it would
> be possible to forward not only to a device, but to this named socket as
> well. All should be very light.
>
>
>>
>> FWIW I've been looking at the problem of RDS over TCP, which is
>> an instance of layered sockets that tunnels the application payload
>> in TCP.
>>
>> RDS over IB provides QoS support using the features available in
>> IB- to supply an analog of that for RDS-TCP, you'd need to plug
>> into tc's CBQ support, and also provide hooks for packet (.1p, dscp)
>> marking.
>>
>> Perhaps there is some overlap to what you are thinking of in #6 and #7
>> above?
>
> I'm not talking about QoS at all. See the description above.
>
> Jiri
>
>>
>> --Sowmini
