From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: Re: [PATCH RFC] Per route TCP options
Date: Wed, 21 Oct 2009 10:04:06 +0200
Message-ID: <4ADEC076.2030105@codefidence.com>
References: <1256052161-14156-1-git-send-email-gilad@codefidence.com> <4ADDE4C4.5080501@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ori@comsleep.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:39177 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447AbZJUIEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 04:04:06 -0400
In-Reply-To: <4ADDE4C4.5080501@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones wrote:

> Gilad Ben-Yossef wrote:
>> Turn the global sysctls allowing disabling of TCP SACK, DSCAK,
>> time stamp and window scale into per route entry feature options,
>> laying the ground to future removal of the relevant global sysctls.
>>
>> You really only want to disable SACK, DSACK, time stamp or window
>> scale if you've got a piece of broken networking equipment somewhere 
>> as a stop gap until you can bring a big enough hammer to deal with
>> the broken network equipment. It doesn't make sense to "punish" the
>> entire connections going through the machine to destinations not 
>> related to the broken equipment.
>
> Is it really only the case that those options get disabled for broken 
> networking equipment?  Does this presage making all TCP options 
> per-route only?
Well, I assume it might be the case that there are situations where you 
are trying to communicate over some exotic link  where the networking 
equipment is not broken as such, but the unusual properties of the link 
makes one of the features not desirable. I can't think of such a 
situation right now off the top of my head, but maybe they exist.

The point is that even then you are more then likely to wish to turn off 
these options to specific destination and routes (that go over said 
exotic link) and keep using them over others - e.g. timestamp OK for 
local LAN, but for default route that goes over exotic TCP/IP over 
carrier penguins turn it off.

To sum it up, I think making these options per route is a win no matter 
the situation. The question I am less certain about if it is also 
desirable to have a global kill switch in addition to the per route 
options. My gut feeling is that this is not needed once you have a per 
route option.

Cheers,
Gilad



-- 
Gilad Ben-Yossef
Chief Coffee Drinker & CTO
Codefidence Ltd.

Web:   http://codefidence.com
Cell:  +972-52-8260388
Skype: gilad_codefidence
Tel:   +972-8-9316883 ext. 201
Fax:   +972-8-9316884
Email: gilad@codefidence.com

Check out our Open Source technology and training blog - http://tuxology.net

	"Sorry cannot parse this, its too long to be true  :)"
	  -- Eric Dumazet on netdev mailing list

