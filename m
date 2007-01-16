From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 0/59] Cleanup sysctl
Date: Tue, 16 Jan 2007 12:30:53 -0700
Message-ID: <m11wlubwgi.fsf@ebiederm.dsl.xmission.com>
References: <m1ac0jc4no.fsf@ebiederm.dsl.xmission.com>
	<45AD02FF.605@zytor.com> <m164b6den7.fsf@ebiederm.dsl.xmission.com>
	<45AD1AD7.7030804@zytor.com>
	<m1ac0iby5q.fsf@ebiederm.dsl.xmission.com>
	<45AD2042.9090701@zytor.com>
	<m164b6bxpz.fsf@ebiederm.dsl.xmission.com>
	<45AD2439.6000406@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	Tony Luck <tony.luck@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:34079 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287AbXAPTb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jan 2007 14:31:26 -0500
To: "H. Peter Anvin" <hpa@zytor.com>
In-Reply-To: <45AD2439.6000406@zytor.com> (H. Peter Anvin's message of "Tue,
	16 Jan 2007 11:15:05 -0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"H. Peter Anvin" <hpa@zytor.com> writes:

> Eric W. Biederman wrote:
>>>
>>> Agreed.  *Furthermore*, if the number isn't in <linux/sysctl.h> it shouldn't
>>> exist anywhere else, either.
>>
>> That would be a good habit.  Feel free to send the patches to ensure that
>> is so.
>>
>> I'm a practical fix it when it is in my way kind of guy ;)
>
> That's fine.  However, I am wondering if there are things in <linux/sysctl.h>
> which really doesn't need architectural numbers, i.e. which should be removed
> from the binary interface.

As a practical measure the 32bit hierarchical numeric namespace is extremely
sparsely populated.  So even if there are things that we never intend to export
again it doesn't hurt to reserve the number for them so we don't confuse something
that thought the number actually meant something.

In the worst case we want to comment out the entry so we keep the number
reserved even if we don't use it.

To see if there are entries we are not currently using just requires
going through the loop.

<pseudo shell>
For DEFINE in sysctl.h ; do
   if ! grep -r DEFINE /usr/src/linux/ ; then
   	echo DEFINE not used.
   fi
done
</pseudo shell>

Eric
