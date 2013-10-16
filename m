From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC] bridge and friends: reduce TheLinuxWay(tm)
Date: Wed, 16 Oct 2013 09:54:57 -0400
Message-ID: <525E9AB1.6090502@mojatatu.com>
References: <525C62D5.3090004@mojatatu.com> <20131014144156.6dc52a78@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f174.google.com ([209.85.213.174]:41995 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934252Ab3JPNzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 09:55:08 -0400
Received: by mail-ye0-f174.google.com with SMTP id l2so151905yen.5
        for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 06:55:07 -0700 (PDT)
In-Reply-To: <20131014144156.6dc52a78@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/14/13 17:41, Stephen Hemminger wrote:

> Unfortunately, by now this is all set in ABI.
> It was a side effect of the per-feature evolutionary style of development.

Sadly, I agree. This is the dark side of "have code will travel";
you let these things out in the wild, they breed and you cant
take them back.
BTW: I dont think what i suggested will be a harmful refactoring because
no existing interfaces are removed - your call.

In similar vein:
What is the motivation behind IFLA_EXT_MASK? Could you not have used
ifm ifindex to relay the interface of interest? Currently the ifindex is
not used at all. IMO, the following interfaces are useful:
- get attributes for all bridge ports (this is there)
- get attributes for bridge interface XXX; there using IFLA_EXT_MASK
I think it should be using ifm->ifindex
- get attributes for all bridge ports for bridge br-blah (not there)
you could also use the ifindex of br-blah here instead

Separate issue:
To provide equivalence to brctl:
- PF_BRIDGE should allow me to attach a bridge port to bridge of choice
with SETLINK

cheers,
jamal
