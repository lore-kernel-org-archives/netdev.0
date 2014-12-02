From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Tue, 2 Dec 2014 10:12:04 -0800
Message-ID: <CAEP_g=-86Z6pxNow-wjnbx_v9er_TSn6x5waigqVqYHa7tEQJw@mail.gmail.com>
References: <1417156385-18276-1-git-send-email-fan.du@intel.com>
 <1417158128.3268.2@smtp.corp.redhat.com> <5A90DA2E42F8AE43BC4A093BF0678848DED92B@SHSMSX104.ccr.corp.intel.com>
 <20141201135225.GA16814@casper.infradead.org> <20141202154839.GB5344@t520.home>
 <20141202170927.GA9457@casper.infradead.org> <20141202173401.GB4126@redhat.com>
 <20141202174158.GB9457@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	"Du, Fan" <fan.du@intel.com>, Jason Wang <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"fw@strlen.de" <fw@strlen.de>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Pravin Shelar <pshelar@nicira.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog017.obsmtp.com ([74.125.150.74]:39384 "HELO
	na6sys009bog017.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932551AbaLBSM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 13:12:26 -0500
Received: by mail-qa0-f43.google.com with SMTP id bm13so9088473qab.2
        for <netdev@vger.kernel.org>; Tue, 02 Dec 2014 10:12:25 -0800 (PST)
In-Reply-To: <20141202174158.GB9457@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 2, 2014 at 9:41 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 12/02/14 at 07:34pm, Michael S. Tsirkin wrote:
>> On Tue, Dec 02, 2014 at 05:09:27PM +0000, Thomas Graf wrote:
>> > On 12/02/14 at 01:48pm, Flavio Leitner wrote:
>> > > What about containers or any other virtualization environment that
>> > > doesn't use Virtio?
>> >
>> > The host can dictate the MTU in that case for both veth or OVS
>> > internal which would be primary container plumbing techniques.
>>
>> It typically can't do this easily for VMs with emulated devices:
>> real ethernet uses a fixed MTU.
>>
>> IMHO it's confusing to suggest MTU as a fix for this bug, it's
>> an unrelated optimization.
>> ICMP_DEST_UNREACH/ICMP_FRAG_NEEDED is the right fix here.
>
> PMTU discovery only resolves the issue if an actual IP stack is
> running inside the VM. This may not be the case at all.

It's also only really a correct thing to do if the ICMP packet is
coming from an L3 node. If you are doing straight bridging then you
have to resort to hacks like OVS had before, which I agree are not
particularly desirable.

> I agree that exposing an MTU towards the guest is not applicable
> in all situations, in particular because it is difficult to decide
> what MTU to expose. It is a relatively elegant solution in a lot
> of virtualization host cases hooked up to an orchestration system
> though.

I also think this is the right thing to do as a common case
optimization and I know other platforms (such as Hyper-V) do it. It's
not a complete solution so we still need the original patch in this
thread to handle things transparently.
