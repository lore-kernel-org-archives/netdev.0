From: "Wangnan (F)" <wangnan0@huawei.com>
Subject: Re: [PATCH 1/8] tools lib bpf: add error functions
Date: Wed, 19 Oct 2016 09:53:12 +0800
Message-ID: <5806D208.90308@huawei.com>
References: <20161016211834.11732-1-eric@regit.org>
 <20161016211834.11732-2-eric@regit.org>
 <CAPWQB7Fvz=MkHGRVPR924BXzuWuLn6VTqaNGR+x_TYhycdOLag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <ast@fb.com>
To: Joe Stringer <joe@ovn.org>, Eric Leblond <eric@regit.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPWQB7Fvz=MkHGRVPR924BXzuWuLn6VTqaNGR+x_TYhycdOLag@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2016/10/19 6:52, Joe Stringer wrote:
> On 16 October 2016 at 14:18, Eric Leblond <eric@regit.org> wrote:
>> The include of err.h is not explicitely needed in exported
>> functions and it was causing include conflict with some existing
>> code due to redefining some macros.
>>
>> To fix this, let's have error handling functions provided by the
>> library. Furthermore this will allow user to have an homogeneous
>> API.
>>
>> Signed-off-by: Eric Leblond <eric@regit.org>
> Does it need to return the error like this or should we just fix up
> the bpf_object__open() API to return errors in a simpler form?
>
> There's already libbpf_set_print(...) for outputting errors, is it
> reasonable to just change the library to return NULLs in error cases
> instead?

Returning error code to caller so caller knows what happen.
Other subsystems in perf also do this.

Perf hides libbpf's error output (make it silent unless -v),
so it needs a way for receiving libbpf's error code.

I think this patch is good, decouple libbpf.h and kernel headers.

Thank you.
