From: "Du, Fan" <fan.du@intel.com>
Subject: RE: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Wed, 3 Dec 2014 02:31:45 +0000
Message-ID: <5A90DA2E42F8AE43BC4A093BF0678848DEDFDB@SHSMSX104.ccr.corp.intel.com>
References: <1417156385-18276-1-git-send-email-fan.du@intel.com>
 <1417158128.3268.2@smtp.corp.redhat.com>
 <5A90DA2E42F8AE43BC4A093BF0678848DED92B@SHSMSX104.ccr.corp.intel.com>
 <20141201135225.GA16814@casper.infradead.org>
 <20141202154839.GB5344@t520.home>
 <20141202170927.GA9457@casper.infradead.org>
 <20141202173401.GB4126@redhat.com>
 <20141202174158.GB9457@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: 'Jason Wang' <jasowang@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"fw@strlen.de" <fw@strlen.de>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"pshelar@nicira.com" <pshelar@nicira.com>,
	"Du, Fan" <fan.du@intel.com>
To: Thomas Graf <tgraf@suug.ch>, "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42853 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751043AbaLCCb4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 21:31:56 -0500
In-Reply-To: <20141202174158.GB9457@casper.infradead.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Thomas Graf [mailto:tgr@infradead.org] On Behalf Of Thomas Graf
>Sent: Wednesday, December 3, 2014 1:42 AM
>To: Michael S. Tsirkin
>Cc: Du, Fan; 'Jason Wang'; netdev@vger.kernel.org; davem@davemloft.net;
>fw@strlen.de; dev@openvswitch.org; jesse@nicira.com; pshelar@nicira.com
>Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
>
>On 12/02/14 at 07:34pm, Michael S. Tsirkin wrote:
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
>> IMHO it's confusing to suggest MTU as a fix for this bug, it's an
>> unrelated optimization.
>> ICMP_DEST_UNREACH/ICMP_FRAG_NEEDED is the right fix here.
>
>PMTU discovery only resolves the issue if an actual IP stack is running inside the
>VM. This may not be the case at all.
 ^^^^^^^^^^^^^^^^^^^^^^^^^^^

Some thoughts here:

Think otherwise, this is indeed what host stack should forge a ICMP_DEST_UNREACH/ICMP_FRAG_NEEDED
message with _inner_ skb network and transport header, do whatever type of encapsulation,
and thereafter push such packet upward to Guest/Container, which make them feel, the intermediate node
or the peer send such message. PMTU should be expected to work correct.
And such behavior should be shared by all other encapsulation tech if they are also suffered.


>I agree that exposing an MTU towards the guest is not applicable in all situations,
>in particular because it is difficult to decide what MTU to expose. It is a relatively
>elegant solution in a lot of virtualization host cases hooked up to an orchestration
>system though.
