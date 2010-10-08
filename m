From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] sysctl: fix min/max handling in
	__do_proc_doulongvec_minmax()
Date: Sat, 9 Oct 2010 00:22:26 +0800
Message-ID: <20101008162226.GA5724@hack>
References: <20101004103545.GJ5189@cr0.nay.redhat.com> <1286188701.18293.57.camel@edumazet-laptop> <20101005130117.GK5170@cr0.nay.redhat.com> <20101007071859.GD5471@cr0.nay.redhat.com> <20101007092538.GE5471@cr0.nay.redhat.com> <1286445081.2912.15.camel@edumazet-laptop> <m1iq1e3qnn.fsf@fess.ebiederm.org> <1286470743.2912.276.camel@edumazet-laptop> <20101007121840.ca49e2ac.akpm@linux-foundation.org> <m1vd5d3ia9.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	Robin Holt <holt@sgi.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	James Morris <jmorris@namei.org>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:52872 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753378Ab0JHQUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 12:20:37 -0400
Content-Disposition: inline
In-Reply-To: <m1vd5d3ia9.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 07, 2010 at 12:38:22PM -0700, Eric W. Biederman wrote:
>Andrew Morton <akpm@linux-foundation.org> writes:
>
>> On Thu, 07 Oct 2010 18:59:03 +0200
>> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>>> Thats fine by me, thanks Eric.
>>> 
>>> Andrew, please remove previous patch from your tree and replace it by
>>> following one :
>>> 
>>> [PATCH v2] sysctl: fix min/max handling in __do_proc_doulongvec_minmax()
>>> 
>>> When proc_doulongvec_minmax() is used with an array of longs,
>>> and no min/max check requested (.extra1 or .extra2 being NULL), we
>>> dereference a NULL pointer for the second element of the array.
>>> 
>>> Noticed while doing some changes in network stack for the "16TB problem"
>>> 
>>> Fix is to not change min & max pointers in
>>> __do_proc_doulongvec_minmax(), so that all elements of the vector share
>>> an unique min/max limit, like proc_dointvec_minmax().
>>> 
>>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>>> ---
>>>  kernel/sysctl.c |    2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>> 
>>> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
>>> index f88552c..8e45451 100644
>>> --- a/kernel/sysctl.c
>>> +++ b/kernel/sysctl.c
>>> @@ -2485,7 +2485,7 @@ static int __do_proc_doulongvec_minmax(void *data, struct ctl_table *table, int
>>>  		kbuf[left] = 0;
>>>  	}
>>>  
>>> -	for (; left && vleft--; i++, min++, max++, first=0) {
>>> +	for (; left && vleft--; i++, first=0) {
>>>  		unsigned long val;
>>>  
>>>  		if (write) {
>>
>> Did we check to see whether any present callers are passing in pointers
>> to arrays of min/max values?
>
>In 2.6.36 there are not any callers that pass in a vector of anything, I
>don't know about linux-next.  It looks to me like incrementing min and
>max was simply a bug.
>

Agreed, I checked them too.

>> I wonder if there's any documentation for this interface which just
>> became wrong.
>
>Or it just became right.  Clearly no one has been expecting min
>and max to be vectors.
>

I think we need to document this before we rewrite the code.

-- 
Live like a child, think like the god.
 
