From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [RFC] Geographical/regulatory information for ieee80211
Date: Wed, 26 Apr 2006 19:54:31 -0500
Message-ID: <44501647.8070308@lwfinger.net>
References: <443EF3E9.7050303@lwfinger.net> <20060415174734.GA10595@infradead.org> <4443D694.8090809@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:39088 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1750959AbWD0Ayj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 20:54:39 -0400
To: Rick Jones <rick.jones2@hp.com>,
	Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org
In-Reply-To: <4443D694.8090809@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> Christoph Hellwig wrote:
>> On Thu, Apr 13, 2006 at 07:59:21PM -0500, Larry Finger wrote:
>>
>>> I am planning on writing a new routine to be added to 
>>> net/ieee80211/ieee80211_geo.c that will populate an ieee80211_geo 
>>> object given a country code. The new routine will eliminate the need 
>>> for each driver to do their own.
>>
>>
>> This sounds like a generally good idea, but the question is:  do we want
>> this inside a kernel module or in userspace, either like the regulartory
>> daemon intel has (unfortunately in binary only form) or as a simple init
>> script.  I really don't want to recompile my kernel just because 
>> regulations
>> changed, and they seems to do that quite often.
> 
> Yet I would expect the regulatory bodies to look less favorably on 
> something more easily maleable by the end-user.

I don't think it would make that much difference as the user could easily lie about their locality 
and get any set of parameters that they wanted. Intel avoids this problem by hiding the locality in 
an EEPROM (ipw2200) or by combining the EEPROM information with the binary-only daemon (3945).

I am leaning toward putting the geographical information into a userland daemon. That way we won't 
have to patch the kernel every time a country modifies its regulations. In addition, the kernel will 
be smaller. The downside is that the daemon will have to be updated and supplied in some convenient 
form, perhaps as part of a wireless tools package.

Larry
