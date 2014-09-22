From: Tom Herbert <therbert@google.com>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink API
Date: Mon, 22 Sep 2014 08:10:08 -0700
Message-ID: <CA+mtBx-ZvkZ2ALGLsLEN7Cgn9gN_rY36ZhuqYC3mZ9WVxjFDaQ@mail.gmail.com>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us>
	<1411134590-4586-9-git-send-email-jiri@resnulli.us>
	<541C4AFC.8060500@mojatatu.com>
	<20140919154946.GH1980@nanopsycho.orion>
	<541C6E6D.9000109@mojatatu.com>
	<541CAA3C.5080105@intel.com>
	<20140920081426.GE1821@nanopsycho.orion>
	<20140920105354.GA29419@casper.infradead.org>
	<CAADnVQK0wT2Fjqdg+C=ruSt8jF6sKeMo7cFj7K1fsu7-1u5g=g@mail.gmail.com>
	<20140922081341.GA20905@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Andy Zhou <azhou@nicira.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Vladislav Yasevich <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:56156 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070AbaIVPKJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 11:10:09 -0400
Received: by mail-ie0-f179.google.com with SMTP id tp5so2788169ieb.38
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 08:10:08 -0700 (PDT)
In-Reply-To: <20140922081341.GA20905@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 22, 2014 at 1:13 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 09/20/14 at 03:50pm, Alexei Starovoitov wrote:
>> I think HW should not be limited by SW abstractions whether
>> these abstractions are called flows, n-tuples, bridge or else.
>> Really looking forward to see "device reporting the headers as
>> header fields (len, offset) and the associated parse graph"
>> as the first step.
>>
>> Another topic that this discussion didn't cover yet is how this
>> all connects to tunnels and what is 'tunnel offloading'.
>> imo flow offloading by itself serves only academic interest.
>
> We haven't touched encryption yet either ;-)
>
> Certainly true for the host case. The Linux on TOR case is less
> dependant on this and L2/L3 offload w/o encap already has value.
>
Thomas, can you (or someone else) quantify what the host case is. I
suppose there may be merit in using a switch on NIC for kernel bypass
scenarios, but I'm still having a hard time understanding how this
could be integrated into the host stack with benefits that outweigh
complexity. The history of stateful offloads in NICs is not great, and
encapsulation (stuffing a few bytes of header into a packet) is in
itself not nearly an expensive enough operation to warrant offloading
to the NIC. Personally, I wish if NIC vendors are going to focus on
stateful offload I rather see it be for encryption which I believe
currently does warrant offload at 40G and higher speeds.

Tom

> I'm with you though, all of this has little value on the host in
> the DC if stateful encap offload is not incorporated. I expect the
> HW to provide filters on the outer header plus metadata in the
> encap. Actually, this was a follow-up question I had for John as
> this is not easily describable with offset/len filters. How would
> we represent such capabilities?
>
> The TX side of this was one of the reasons why I initially thought
> it would be beneficial to implement a cache like offload as we could
> serve an initial encap in SW, do the FIB lookup and offload it
> transparently to avoid replicating the FIB in user space.
>
> What seems most feasisble to me right now is to separate the offload
> of the encap action from the IP -> dev mapping decision. The eSwitch
> would send the first encap for an unknown dest IP to the CPU due
> to a miss in the IP mapping table, the CPU would do the FIB lookup,
> update the table and send it back.
>
> What do you have in mind?
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
