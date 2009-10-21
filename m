From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH v2 1/8] Only parse time stamp TCP option in time wait
 sock
Date: Wed, 21 Oct 2009 14:59:59 -0400
Message-ID: <4ADF5A2F.9010309@gmail.com>
References: <1256115421-12714-1-git-send-email-gilad@codefidence.com> <1256115421-12714-2-git-send-email-gilad@codefidence.com> <4ADED915.7000107@gmail.com> <4ADEDD65.6070802@codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.186]:27071 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754111AbZJUTH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 15:07:56 -0400
Received: by gv-out-0910.google.com with SMTP id r4so841407gve.37
        for <netdev@vger.kernel.org>; Wed, 21 Oct 2009 12:08:00 -0700 (PDT)
In-Reply-To: <4ADEDD65.6070802@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gilad Ben-Yossef wrote:
> William Allen Simpson wrote:
> 
>> Gilad Ben-Yossef wrote:
>>> A time wait socket is established - we already know if time stamp
>>> option is called for or not.
>>>
>> Not so sure about this.  A timewait sock isn't actually established,
>> and new/changed options could appear.  There's all sorts of edge cases.
> If you examine the specific context where tcp_parse_options is being 
> called here,
> the only TCP option which is of interest is the time stamp option, and 
> this code path
> is only being taken when we already know that the original socket  had
> used the time stamp option.
> 
> So while I agree that in general you are right, I do believe that in the 
> specific context
> of this patch we should call tcp_parse_options with the established flag 
> on and let it
> know we are expecting to see a time stamp option, which is what I was 
> referring to.
> 
No, a major reason for time-wait is rebooted systems.  We don't "know"
anything about them, and they certainly don't know anything about us.

As I mentioned, this is about edge cases.


>>
>> There's also some current work to note:
>>
>>  http://tools.ietf.org/html/draft-ietf-tcpm-1323bis
>>
>>  http://tools.ietf.org/html/draft-gont-tcpm-tcp-timestamps
> 
> Very interesting, thank you.
> 
> As I noted above, my comment about
> TIME WAIT sockets being "established" should really only be considered
> in the context of the specific call to tcp_parse_options() and the 
> "established"
> parameter of that function.
> 
My suggestion, as this patch is not essential to the other patches in the
series, is to separate it.  As I'm relatively new to this list, I don't
know the best practice.  But I'd like to support the others and delay
this for further consideration.
