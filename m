From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/3] trace: add variant without spacing in trace_print_hex_seq
Date: Wed, 01 Feb 2017 09:10:52 +0100
Message-ID: <5891980C.9020203@iogearbox.net>
References: <cover.1485306168.git.daniel@iogearbox.net> <f860273ed9fd0c423f4d1ee2ab93565992d76ff4.1485306168.git.daniel@iogearbox.net> <20170130154425.581bf631@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, ast@kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@redhat.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170130154425.581bf631@gandalf.local.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/30/2017 09:44 PM, Steven Rostedt wrote:
> On Wed, 25 Jan 2017 02:28:16 +0100
> Daniel Borkmann <daniel@iogearbox.net> wrote:
>
>> For upcoming tracepoint support for BPF, we want to dump the program's
>> tag. Format should be similar to __print_hex(), but without spacing.
>> Add a __print_hex_str() variant for exactly that purpose that reuses
>> trace_print_hex_seq().
>>
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>> Cc: Steven Rostedt <rostedt@goodmis.org>
>> Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
>> ---
>>   include/linux/trace_events.h | 3 ++-
>>   include/trace/trace_events.h | 8 +++++++-
>>   kernel/trace/trace_output.c  | 7 ++++---
>>   3 files changed, 13 insertions(+), 5 deletions(-)
>>
>> diff --git a/include/linux/trace_events.h b/include/linux/trace_events.h
>> index be00761..cfa475a 100644
>> --- a/include/linux/trace_events.h
>> +++ b/include/linux/trace_events.h
>> @@ -33,7 +33,8 @@ const char *trace_print_bitmask_seq(struct trace_seq *p, void *bitmask_ptr,
>>   				    unsigned int bitmask_size);
>>
>>   const char *trace_print_hex_seq(struct trace_seq *p,
>> -				const unsigned char *buf, int len);
>> +				const unsigned char *buf, int len,
>> +				bool spacing);
>
> Hmm, "spacing" doesn't really mean much. What about the invert of it,
> and have "concatenate"?

Sure, I'm fine with that.

>>   const char *trace_print_array_seq(struct trace_seq *p,
>>   				   const void *buf, int count,
>> diff --git a/include/trace/trace_events.h b/include/trace/trace_events.h
>> index 467e12f..9f68462 100644
>> --- a/include/trace/trace_events.h
>> +++ b/include/trace/trace_events.h
>> @@ -297,7 +297,12 @@
>>   #endif
>>
>>   #undef __print_hex
>> -#define __print_hex(buf, buf_len) trace_print_hex_seq(p, buf, buf_len)
>> +#define __print_hex(buf, buf_len)					\
>> +	trace_print_hex_seq(p, buf, buf_len, true)
>> +
>> +#undef __print_hex_str
>> +#define __print_hex_str(buf, buf_len)					\
>> +	trace_print_hex_seq(p, buf, buf_len, false)
>>
>>   #undef __print_array
>>   #define __print_array(array, count, el_size)				\
>> @@ -711,6 +716,7 @@
>>   #undef __print_flags
>>   #undef __print_symbolic
>>   #undef __print_hex
>> +#undef __print_hex_str
>>   #undef __get_dynamic_array
>>   #undef __get_dynamic_array_len
>>   #undef __get_str
>> diff --git a/kernel/trace/trace_output.c b/kernel/trace/trace_output.c
>> index 5d33a73..30a144b1 100644
>> --- a/kernel/trace/trace_output.c
>> +++ b/kernel/trace/trace_output.c
>> @@ -163,14 +163,15 @@ enum print_line_t trace_print_printk_msg_only(struct trace_iterator *iter)
>>   EXPORT_SYMBOL_GPL(trace_print_bitmask_seq);
>
> With the addition of this boolean parameter, this function shold
> probably have a kernel doc header, that can explain the parameters.

Yeah, I can add that. Since the patch got already applied, I will send
a follow-up for adding the kdoc and for changing the bool logic/name as
concatenate.

Thanks for your review!
Daniel
