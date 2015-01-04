From: Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>
Subject: Re: Re: [PATCH v3 05/20] selftests/ftrace: add install target
 to enable test install
Date: Sun, 04 Jan 2015 14:18:06 +0900
Message-ID: <54A8CD0E.1030609@hitachi.com>
References: <cover.1419387513.git.shuahkh@osg.samsung.com> <e84eeeecde70ecb3ab82c5f825fec359f9e967ff.1419387513.git.shuahkh@osg.samsung.com> <20150102104526.29df5641@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>, mmarek-AlSwsSmVLrQ@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
	tranmanphong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, mpe-Gsx/Oe8HsFggBc27wqDAHg@public.gmane.org, cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, hughd-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, bobby.prani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org,
	tim.bird-/MT0OVThwyLZJqsBc5GL+g@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, koct9i-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-kbuild-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150102104526.29df5641-f9ZlEuEWxVcJvu8Pb33WZ0EMvNT87kid@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(2015/01/03 0:45), Steven Rostedt wrote:
> On Wed, 24 Dec 2014 09:27:41 -0700
> Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org> wrote:
> 
>> Add a new make target to enable installing test. This target
>> installs test in the kselftest install location and add to the
>> kselftest script to run the test. Install target can be run
>> only from top level kernel source directory.
>>
>> Signed-off-by: Shuah Khan <shuahkh-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
>> ---
>>  tools/testing/selftests/ftrace/Makefile | 11 ++++++++++-
>>  1 file changed, 10 insertions(+), 1 deletion(-)
>>
>> diff --git a/tools/testing/selftests/ftrace/Makefile b/tools/testing/selftests/ftrace/Makefile
>> index 76cc9f1..7c7cf42 100644
>> --- a/tools/testing/selftests/ftrace/Makefile
>> +++ b/tools/testing/selftests/ftrace/Makefile
>> @@ -1,7 +1,16 @@
>> +TEST_STR = /bin/sh ./ftracetest || echo ftrace selftests: [FAIL]
> 
> Is it ok that this removes the quotes around the echo string? I don't
> see anything wrong about it, but I don't know if there's a shell out
> there that will fail due to it.

Agreed, if possible, we'd better add quotes around the echo string
as you did in 2/20 in this series.

Anyway, you can also add my ack to this patch.

Acked-by: Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>

Thank you!

> 
> Other than than,
> 
> Acked-by: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
> 
> -- Steve
> 
> 
>> +
>>  all:
>>  
>> +install:
>> +ifdef INSTALL_KSFT_PATH
>> +	install ./ftracetest $(INSTALL_KSFT_PATH)
>> +	@cp -r test.d $(INSTALL_KSFT_PATH)
>> +	echo "$(TEST_STR)" >> $(KSELFTEST)
>> +endif
>> +
>>  run_tests:
>> -	@/bin/sh ./ftracetest || echo "ftrace selftests: [FAIL]"
>> +	@$(TEST_STR)
>>  
>>  clean:
>>  	rm -rf logs/*
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 


-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org
