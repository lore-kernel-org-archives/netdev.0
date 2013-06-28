From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH net-next 2/2] net: avoid calling sched_clock when LLS
 is off
Date: Fri, 28 Jun 2013 17:54:43 +0300
Message-ID: <51CDA3B3.7010605@linux.intel.com>
References: <20130628125918.14419.36214.stgit@ladj378.jer.intel.com> <20130628125934.14419.38109.stgit@ladj378.jer.intel.com> <20130628143840.GS6123@two.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130628143840.GS6123@two.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 28/06/2013 17:38, Andi Kleen wrote:
>> diff --git a/fs/select.c b/fs/select.c
>> index 79b876e..3654075 100644
>> --- a/fs/select.c
>> +++ b/fs/select.c
>> @@ -402,7 +402,7 @@ int do_select(int n, fd_set_bits *fds, struct timespec *end_time)
>>   	poll_table *wait;
>>   	int retval, i, timed_out = 0;
>>   	unsigned long slack = 0;
>> -	unsigned int ll_flag = POLL_LL;
>> +	unsigned int ll_flag = ll_get_flag();
>
> Is that a global flag? That's still the wrong level. It should
> look at something in the file descriptor (preferably without
> fetching any new cache lines)
>

There is a global flag that decides if we even try to find supported
files (sockets).

If it is on we look to see if anyone will return POLL_LL.
at the individual socket level, you need both the socket option to
be on, and the queue data to be available for it to return POLL_LL.

I wanted to find a way to control this at the time the user calls poll().
I was not able to find any simple way of doing it that way.
I'm open to suggestion.
