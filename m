From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 11/15] userns: Teach trace to use from_kuid
Date: Sat, 25 Aug 2012 17:28:02 -0700
Message-ID: <87mx1icx9p.fsf@xmission.com>
References: <87lih2h6i4.fsf@xmission.com> <87wr0mecxz.fsf@xmission.com>
	<1345940316.19381.1.camel@pippen.local.home>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Ingo Molnar <mingo@redhat.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1345940316.19381.1.camel@pippen.local.home> (Steven Rostedt's
	message of "Sat, 25 Aug 2012 20:18:36 -0400")
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steven Rostedt <rostedt@goodmis.org> writes:

> On Sat, 2012-08-25 at 17:04 -0700, Eric W. Biederman wrote:
>> - When tracing capture the kuid.
>> - When displaying the data to user space convert the kuid into the
>>   user namespace of the process that opened the report file.
>> 
>
>> index 5c38c81..c9ace83 100644
>> --- a/kernel/trace/trace.c
>> +++ b/kernel/trace/trace.c
>> @@ -2060,7 +2060,8 @@ print_trace_header(struct seq_file *m, struct trace_iterator *iter)
>>  	seq_puts(m, "#    -----------------\n");
>>  	seq_printf(m, "#    | task: %.16s-%d "
>>  		   "(uid:%d nice:%ld policy:%ld rt_prio:%ld)\n",
>> -		   data->comm, data->pid, data->uid, data->nice,
>> +		   data->comm, data->pid,
>> +		   from_kuid_munged(seq_user_ns(m), data->uid), data->nice,
>
> This is a global id. That is, it stored whatever process triggered the
> report, not the one reading it. Thus, two different readers could get a
> different uid for the same task that triggered the latency?

Yes the stored value is a kuid_t the global kernel internal form.

We report the value as a uid_t in the user namespace of the reader.  So
if two different processes in different user namespaces read the file
they can see different values.

Now I don't expect in practice we will allow anyone who isn't
the global root user to even think of looking at debugfs, but in
case we do we might as well handle this as best as we can.

Eric
