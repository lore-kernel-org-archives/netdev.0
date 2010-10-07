From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] sysctl: fix min/max handling in __do_proc_doulongvec_minmax()
Date: Thu, 07 Oct 2010 12:38:22 -0700
Message-ID: <m1vd5d3ia9.fsf@fess.ebiederm.org>
References: <1286025469.2582.1806.camel@edumazet-laptop>
	<20101004085913.GR14068@sgi.com>
	<1286183058.18293.26.camel@edumazet-laptop>
	<20101004093439.GG5189@cr0.nay.redhat.com>
	<1286187030.18293.33.camel@edumazet-laptop>
	<20101004103545.GJ5189@cr0.nay.redhat.com>
	<1286188701.18293.57.camel@edumazet-laptop>
	<20101005130117.GK5170@cr0.nay.redhat.com>
	<20101007071859.GD5471@cr0.nay.redhat.com>
	<20101007092538.GE5471@cr0.nay.redhat.com>
	<1286445081.2912.15.camel@edumazet-laptop>
	<m1iq1e3qnn.fsf@fess.ebiederm.org>
	<1286470743.2912.276.camel@edumazet-laptop>
	<20101007121840.ca49e2ac.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	=?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>,
	Robin Holt <holt@sgi.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	James Morris <jmorris@namei.org>,
	"Pekka Savola \(ipv6\)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101007121840.ca49e2ac.akpm@linux-foundation.org> (Andrew
	Morton's message of "Thu, 7 Oct 2010 12:18:40 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Thu, 07 Oct 2010 18:59:03 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:

>> Thats fine by me, thanks Eric.
>> 
>> Andrew, please remove previous patch from your tree and replace it by
>> following one :
>> 
>> [PATCH v2] sysctl: fix min/max handling in __do_proc_doulongvec_minmax()
>> 
>> When proc_doulongvec_minmax() is used with an array of longs,
>> and no min/max check requested (.extra1 or .extra2 being NULL), we
>> dereference a NULL pointer for the second element of the array.
>> 
>> Noticed while doing some changes in network stack for the "16TB problem"
>> 
>> Fix is to not change min & max pointers in
>> __do_proc_doulongvec_minmax(), so that all elements of the vector share
>> an unique min/max limit, like proc_dointvec_minmax().
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> ---
>>  kernel/sysctl.c |    2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
>> index f88552c..8e45451 100644
>> --- a/kernel/sysctl.c
>> +++ b/kernel/sysctl.c
>> @@ -2485,7 +2485,7 @@ static int __do_proc_doulongvec_minmax(void *data, struct ctl_table *table, int
>>  		kbuf[left] = 0;
>>  	}
>>  
>> -	for (; left && vleft--; i++, min++, max++, first=0) {
>> +	for (; left && vleft--; i++, first=0) {
>>  		unsigned long val;
>>  
>>  		if (write) {
>
> Did we check to see whether any present callers are passing in pointers
> to arrays of min/max values?

In 2.6.36 there are not any callers that pass in a vector of anything, I
don't know about linux-next.  It looks to me like incrementing min and
max was simply a bug.

> I wonder if there's any documentation for this interface which just
> became wrong.

Or it just became right.  Clearly no one has been expecting min
and max to be vectors.

Eric
