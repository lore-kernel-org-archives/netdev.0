From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: Re: [PATCH v2 1/8] Only parse time stamp TCP option in time wait
 sock
Date: Wed, 21 Oct 2009 12:07:33 +0200
Message-ID: <4ADEDD65.6070802@codefidence.com>
References: <1256115421-12714-1-git-send-email-gilad@codefidence.com> <1256115421-12714-2-git-send-email-gilad@codefidence.com> <4ADED915.7000107@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:38153 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243AbZJUKHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 06:07:32 -0400
In-Reply-To: <4ADED915.7000107@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

William Allen Simpson wrote:

> Gilad Ben-Yossef wrote:
>> A time wait socket is established - we already know if time stamp
>> option is called for or not.
>>
> Not so sure about this.  A timewait sock isn't actually established,
> and new/changed options could appear.  There's all sorts of edge cases.
If you examine the specific context where tcp_parse_options is being 
called here,
the only TCP option which is of interest is the time stamp option, and 
this code path
is only being taken when we already know that the original socket  had
used the time stamp option.

So while I agree that in general you are right, I do believe that in the 
specific context
of this patch we should call tcp_parse_options with the established flag 
on and let it
know we are expecting to see a time stamp option, which is what I was 
referring to.

>
> There's also some current work to note:
>
>  http://tools.ietf.org/html/draft-ietf-tcpm-1323bis
>
>  http://tools.ietf.org/html/draft-gont-tcpm-tcp-timestamps

Very interesting, thank you.

As I noted above, my comment about
TIME WAIT sockets being "established" should really only be considered
in the context of the specific call to tcp_parse_options() and the 
"established"
parameter of that function.

Thanks,
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

