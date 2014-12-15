From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next v2 2/4] swdevice: add new api to set and del
 bridge port attributes
Date: Mon, 15 Dec 2014 18:27:30 -0500
Message-ID: <548F6E62.1040500@mojatatu.com>
References: <1418202320-19491-3-git-send-email-roopa@cumulusnetworks.com> <20141210093755.GB1863@nanopsycho.orion> <5489CBBA.7050302@cumulusnetworks.com> <20141211171145.GG1912@nanopsycho.orion> <5489DB73.1080808@cumulusnetworks.com> <20141211180743.GA2010@nanopsycho.orion> <5489E214.4080708@cumulusnetworks.com> <20141211222559.GB1880@nanopsycho.orion> <548D9B14.9010201@cumulusnetworks.com> <20141214153549.GA2174@nanopsycho.orion> <548DE7E2.6010705@cumulusnetworks.com> <548EFD94.8070905@mojatatu.com> <E4CD12F19ABA0C4D8729E087A761DC3505D999EA@ORSMSX106.amr.corp.intel.com> <548F20FF.9080508@gmail.com> <E4CD12F19ABA0C4D8729E087A761DC3505D9FA8C@ORSMSX106.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"bcrl@kvack.org" <bcrl@kvack.org>, "tgraf@suug.ch" <tgraf@suug.ch>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"shm@cumulusnetworks.com" <shm@cumulusnetworks.com>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>
To: "Arad, Ronen" <ronen.arad@intel.com>,
	John Fastabend <john.fastabend@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:47298 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751217AbaLOX1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 18:27:33 -0500
Received: by mail-ie0-f169.google.com with SMTP id y20so11868443ier.14
        for <netdev@vger.kernel.org>; Mon, 15 Dec 2014 15:27:32 -0800 (PST)
In-Reply-To: <E4CD12F19ABA0C4D8729E087A761DC3505D9FA8C@ORSMSX106.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/15/14 13:36, Arad, Ronen wrote:
>
>
>> -----Original Message-----

> The behavior of a driver could depend on the presence of a bridge and features such as FDB LEARNING and LEARNING_SYNC.

Indeed, those are bridge attributes.

> A switch port driver which is not enslaved to a bridge might need to implement VLAN-aware FDB
>within the driver and report its content to user-space using ndo_fdb_dump.
 >
> A switch port driver which is enslaved to a bridge could do with only pass through for static FDB configuration
 > to the HW when LEARNING_SYNC is configured. FDB reporting to 
user-space and soft aging are left to the bridge module FDB.
> Such driver, without LEARNING_SYNC could still avoid maintaing in-driver FDB as long as it could dump the HW FDB on demand.
> LEARNING_SYNC also requires periodic updates of freshness information from the driver to the bridge module.
>


If you have an fdb - shouldnt that be exposed only if you have a bridge
abstraction exposed? i.e thats where the Linux tools would work.
What i was refering to was a scenario where i have no interest in the
fdb despite such a hardware capabilities. VLANs is a different issue;

>>> Will the decision about using a bridge device or avoiding it be left
>>> to the end-user?
>>
>> Its a user policy decision. Again the offload bit gets us this in a reasonably
>> configurable way IMO.
>>
>>> (This requires switch port drivers to be able to work and provide
>>> similar functionality in both setups).
>>
>> Right, but if the drivers "care" who is calling their ndo ops something is
>> seriously broken. For the driver it should not need to know anything about
>> the callers so it doesn't matter to the driver if its a netlink call from user
>> space or an internal call fro bridge.ko
>
> LEARNING_SYNC only makes sense when a switch port driver is enslaved to a bridge.
 > Rocker switch driver indeed monitors upper change notifications and 
keep track of master bridge presence.
> So bridge presence is not transparent.
>

Agreed - the challenge so far is that people have been fascinated by
"switch" point of view. I think we are learning and the class device
will eventually become obvious as useful.

cheers,
jamal
