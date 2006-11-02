From: "Horvath, Elmer" <Elmer.Horvath@windriver.com>
Subject: RE: [tipc-discussion] [KJ] [patch] net/tipc:sprintf/strcpy	conversion
Date: Thu, 2 Nov 2006 07:25:01 -0800
Message-ID: <F6AE8F99CFBB884E9681D609D859BAD324D63D@ala-mail02.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:13504 "EHLO mail.wrs.com")
	by vger.kernel.org with ESMTP id S1751380AbWKBPZm convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 10:25:42 -0500
Content-class: urn:content-classes:message
To: <wharms@bfs.de>, <tipc-discussion@lists.sourceforge.net>,
	<kernel-janitors@lists.osdl.org>, <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Florian Westphal wrote:
>> walter harms <wharms@bfs.de> wrote:
>>> These line
>>> +       strcpy(bcbearer->media.name, "tipc-multicast");
>>> i gues that means tipc_bclink_name ?
>> 
>> The idea was to change how things are done, not _what_ is being done.
>> 
>>> an even more secure version could be like this:
>>>
>>>
strncpy(bcbearer->media.name,sizeof(bcbearer->media.name),tipc_bclink_na
me);
>> 
>> Ugh, please, no. The size of src is known in all cases; there is
>> absoluty no point in using str(n|l)cpy here.
>> 
>>> (in case someone ever changes the size of cbearer->media.name or
tipc_bclink_name and the >hope
>>> that wchat_t will never reach the kernel)
>>> 
>> In this case 'someone' should be really hurt, don't you think?
>> 
>
>hi florian,
>i am on the side of error, the code increase is marginal and the speed
penalty also, so why not ?
>you make sure that an overflow may never happen, and the rest in name
gets zeroed.
>
>The problem is that when the error occurs it may be later than the
actual changeset.
>NTL it is an hint, and if you feel ok with it and the maintainer has no
objects i have no >problems either.

>re,
> wh

This objection I would have here is that you have would have to use
strlcpy or you must explicitly set the last byte to '\0'.  strncpy()
will not guarnatee a null-terminated string.  Also, str(n|l)cpy always
writes 'n' bytes whereas strcpy() will only write as many bytes as
required stopping at the null.  This is inefficient.

It would be better to ensure that the sting being copied is correctly
sized when first accepted if this is possible.  I didn't trace the
usage, but it has likely already been checked for size.  No?

Elmer


------------------------------------------------------------------------
-
Using Tomcat but need to do more? Need to support web services,
security?
Get stuff done quickly with pre-integrated technology to make your job
easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache
Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
tipc-discussion mailing list
tipc-discussion@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/tipc-discussion
