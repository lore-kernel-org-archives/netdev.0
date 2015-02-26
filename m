From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 1/8] mpls: Refactor how the mpls module is built
Date: Wed, 25 Feb 2015 20:15:43 -0600
Message-ID: <87bnkhquy8.fsf@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
	<87k2z5x6ch.fsf@x220.int.ebiederm.org>
	<20150226020504.GA935@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	roopa <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:48098 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753063AbbBZCTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 21:19:13 -0500
In-Reply-To: <20150226020504.GA935@verge.net.au> (Simon Horman's message of
	"Thu, 26 Feb 2015 11:05:04 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Horman <horms@verge.net.au> writes:

> On Wed, Feb 25, 2015 at 11:13:02AM -0600, Eric W. Biederman wrote:
>> 
>> This refactoring is needed to allow more than just mpls gso support to
>> be built into the mpls moddule.
>> 
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> ---
>>  net/Makefile     |  2 +-
>>  net/mpls/Kconfig | 18 +++++++++++++++++-
>>  2 files changed, 18 insertions(+), 2 deletions(-)
>> 
>> diff --git a/net/Makefile b/net/Makefile
>> index 38704bdf941a..3995613e5510 100644
>> --- a/net/Makefile
>> +++ b/net/Makefile
>> @@ -69,7 +69,7 @@ obj-$(CONFIG_BATMAN_ADV)	+= batman-adv/
>>  obj-$(CONFIG_NFC)		+= nfc/
>>  obj-$(CONFIG_OPENVSWITCH)	+= openvswitch/
>>  obj-$(CONFIG_VSOCKETS)	+= vmw_vsock/
>> -obj-$(CONFIG_NET_MPLS_GSO)	+= mpls/
>> +obj-$(CONFIG_MPLS)		+= mpls/
>>  obj-$(CONFIG_HSR)		+= hsr/
>>  ifneq ($(CONFIG_NET_SWITCHDEV),)
>>  obj-y				+= switchdev/
>> diff --git a/net/mpls/Kconfig b/net/mpls/Kconfig
>> index 37421db88965..a77fbcdd04ee 100644
>> --- a/net/mpls/Kconfig
>> +++ b/net/mpls/Kconfig
>> @@ -1,9 +1,25 @@
>>  #
>>  # MPLS configuration
>>  #
>> +
>> +menuconfig MPLS
>> +	tristate "MultiProtocol Label Switching"
>> +	default n
>> +	---help---
>> +	  MultiProtocol Label Switching routes packets through logical
>> +	  circuits.  Originally conceved as a way of routing packets at
>> +	  hardware speeds (before hardware was capable of routing ipv4 packets),
>> +	  MPLS remains as simple way of making tunnels.
>> +
>> +	  If you have not heard of MPLS you probably want to say N here.
>> +
>> +if MPLS
>> +
>>  config NET_MPLS_GSO
>> -	tristate "MPLS: GSO support"
>> +	bool "MPLS: GSO support"
>>  	help
>>  	 This is helper module to allow segmentation of non-MPLS GSO packets
>>  	 that have had MPLS stack entries pushed onto them and thus
>>  	 become MPLS GSO packets.
>> +
>> +endif # MPLS
>
> Is the implication here that MPLS must be selected to allow NET_MPLS_GSO to
> be selected? That is if NET_MPLS_GSO is to be used to handle MPLS packets
> emitted by OVS then now MPLS also needs to be selected?

Yes.

That is the way we seem to handle this for other protocols and I could
not see an easy way to build multiple modules from a single Makefile.

I am a tad afraid that this Kconfig clause will cause problems with
make oldconfig as it stands, and I will be happy to take suggestions
on how to do this better.

The other MPLS bits that are added in the following patches are behind
their own Kconfig options so there is no danger in getting more MPLS
code than desired.

Eric
