From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: Re: [PATCH v2 1/8] Only parse time stamp TCP option in time wait
 sock
Date: Sun, 25 Oct 2009 10:41:51 +0200
Message-ID: <4AE40F4F.3020004@codefidence.com>
References: <1256115421-12714-1-git-send-email-gilad@codefidence.com> <1256115421-12714-2-git-send-email-gilad@codefidence.com> <4ADED915.7000107@gmail.com> <4ADEDD65.6070802@codefidence.com> <4ADF5A2F.9010309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:33234 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752452AbZJYIly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2009 04:41:54 -0400
In-Reply-To: <4ADF5A2F.9010309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello William,


William Allen Simpson wrote:


>> If you examine the specific context where tcp_parse_options is being 
>> called here,
>> the only TCP option which is of interest is the time stamp option, 
>> and this code path
>> is only being taken when we already know that the original socket  had
>> used the time stamp option.
>>
>> So while I agree that in general you are right, I do believe that in 
>> the specific context
>> of this patch we should call tcp_parse_options with the established 
>> flag on and let it
>> know we are expecting to see a time stamp option, which is what I was 
>> referring to.
>>
> No, a major reason for time-wait is rebooted systems.  We don't "know"
> anything about them, and they certainly don't know anything about us.
>
> As I mentioned, this is about edge cases.
I just read thoroughly the code in question again -

We use tcp_parse_option to check if there is a time stamp option in the 
packet and if so, get the time stamp from it. We do this only when the 
time wait minisocket has information of time stamp from the original 
connection. We don't use any other TCP option or other inoformation from 
the options read via that call.

The above statements are true both for the original code and my patch. 
If there is any corner case with my code it is true for the original 
code as well.

>
> My suggestion, as this patch is not essential to the other patches in the
> series, is to separate it.  As I'm relatively new to this list, I don't
> know the best practice.  But I'd like to support the others and delay
> this for further consideration.
I have no objection to separate or drop it altogether if there is a 
specific technical reason why you think the code is wrong. It certainly 
is possible I've done some done mistake. In that case, I would love 
nothing more to hearing what it is and hopefully fixing it.

But "Maybe there are edge cases we didn't think about" is not specific 
enough to work upon :-)

Thanks for all the feedback,
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

