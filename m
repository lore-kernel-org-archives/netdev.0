From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: Flows! Offload them.
Date: Mon, 02 Mar 2015 09:16:22 -0500
Message-ID: <54F470B6.8040207@mojatatu.com>
References: <20150226074214.GF2074@nanopsycho.orion> <20150226083758.GA15139@vergenet.net> <20150226091628.GA4059@nanopsycho.orion> <20150226133326.GC23050@casper.infradead.org> <54EF3A78.9020507@intel.com> <20150226201635.GA366@hmsreliant.think-freely.org> <20150226215255.GA15033@penelope.isobedori.kobe.vergenet.net> <20150227012239.GB8847@neilslaptop.think-freely.org> <20150227084141.GA17240@casper.infradead.org> <E4CD12F19ABA0C4D8729E087A761DC35067DC283@ORSMSX101.amr.corp.intel.com> <20150301140547.GB31578@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Simon Horman <simon.horman@netronome.com>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"andy@greyhouse.net" <andy@greyhouse.net>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	"ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
	"jesse@nicira.com" <jesse@nicira.com>,
	"jpettit@nicira.com" <jpettit@nicira.com>,
	"joestringer@nicira.com" <joestringer@nicira.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"shrijeet@gmail.com" <shrijeet@gmail.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"bcrl@kvack.org" <bcrl@kvack.org>,
	Aviad Raveh <aviadr@mellano
To: Neil Horman <nhorman@tuxdriver.com>,
	"Arad, Ronen" <ronen.arad@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:38007 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753339AbbCBOQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 09:16:26 -0500
Received: by iecrd18 with SMTP id rd18so48003412iec.5
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 06:16:25 -0800 (PST)
In-Reply-To: <20150301140547.GB31578@neilslaptop.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/01/15 09:05, Neil Horman wrote:
> On Sun, Mar 01, 2015 at 09:36:43AM +0000, Arad, Ronen wrote:
>>

>> Random offloading of flows does not preserve policy in general.
>> For example let's consider two flows A.B.C.0/24 and A.B.C.D with the more
>> specific rule has higher priority.
>> If only the first rule is offloaded to HW, packets matched by the second
>> rule will not be processed as expected by the user.
>> Deciding which flow could be offloaded is an optimization decision that
>> is better handled outside of the kernel.
>>
> Regarding the description of offload:
> Random is I think a improper term here.  There is nothing random about flow
> offload.  There is only the reality of needing to select which rules to offload,
> as it is inevitable that hardware dataplane capacity won't/can't match that of
> software limits.  All we can do is select which of those flows are offloaded.
> When dealing with offload in the context of an existing sofware function, the
> constraints of selecting which rules those are become fairly clear.  For example
> with routing:
> 1) More specific rules get offloaded first
> 2) on overflow, you replace a rule that conforms to a pre-packaged policy (ex.
> LRU), and iff it doesn't violate (1)


Sounds sane as a starting point. Lets just talk L3 since this applies
to any tcam approach (and expense of repeating things already discussed)
For hook #2 Dave proposes in other email to just flush everything and do
things in s/ware at that point for initial implementation.

[Most people would try to aggregate  things into a /24 for example to
make space for more /32s. And theres all sorts of crazy shit to amortize
tcam space that people do]

But this brings in another requirement: CCing the Mellanox folks who
brought up this  issue numerous times.
Things tend to "freeze" at that point while the kernel is madly moving
things around (as would be the case with Dave's suggested "move all
to software"). At netdev01, Aviad was suggesting that the kernel
respond first with a netlink message "work in progress" or even lie
with "success" if it knows it will accomplish this goal.
Ccing Sol who had a different reason for waiting seconds long for things
to be inserted into hardware.


cheers,
jamal
