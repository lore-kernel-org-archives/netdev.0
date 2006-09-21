From: mabbas <mabbas@linux.intel.com>
Subject: Re: [PATCH 5/7] d80211: indicate if unassociate/radio off status
Date: Thu, 21 Sep 2006 12:47:40 -0700
Message-ID: <4512EC5C.1030807@linux.intel.com>
References: <44F356DF.9000000@linux.intel.com>	 <20060921190126.4d884c44@logostar.upir.cz> <1158865436.27546.23.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:52098 "EHLO
	fmsmga101.fm.intel.com") by vger.kernel.org with ESMTP
	id S1751482AbWIUTrh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Sep 2006 15:47:37 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1158865436.27546.23.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> On Thu, 2006-09-21 at 19:01 +0200, Jiri Benc wrote:
>   
>> On Mon, 28 Aug 2006 13:49:35 -0700, mabbas wrote:
>>     
>>> This patch indicate unassociated and radio off status
>>> in name field
>>>       
>> NAK.
>>
>> Fix SIOCGIWAP handler instead.
>>     
>
> Right; the _one_ place anyone should ever have to check for unassociated
> status is SIOCGIWAP.  That's it.  Lets not put stuff in two different
> places.  If it's all 0s, all 4s (stupid prism) or all Fs (i forget who
> does that), it's invalid and you're not connected.
>
> About the worst thing we can start doing is having to parse arbitrary
> strings to find out driver/card status.  That's the same problem with
> "<hidden>" which hope DIES DIES DIES with d80211.  If the AP is hidden,
> then it has a _blank_ SSID, not hacked to "<hidden>".
>
> For radio off, that may be a legitimate thing that's not covered in WE
> yet.  But isn't that the domain of SIOCGIWPOWER, or is that just used to
> set PM modes and not return current status? [1]
>
> Dan
>
> [1] which would seem like an oversight to correct in nl80211
>
>   

SIOCGIWPOWER is for power save mode it has nothing to do with radio off, we can 
indicate radio off in txpower field i guess. I have question regarding SIOCGIWAP. if
I do #iwconfig ap 00:13:23:87:150:150, wont iwconfig always show  00:13:23:87:150:150 
for SIOCGIWAP regardless if we associated or not? can we display blank in this case to 
indicate not connected?
Mohamed 

 

>>  Jiri
>>
>>     
