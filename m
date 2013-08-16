From: "Carlos O'Donell" <carlos@redhat.com>
Subject: Re: [GLIBC Patch v2] inet: avoid redefinition of some structs in
 kernel
Date: Fri, 16 Aug 2013 11:44:35 -0400
Message-ID: <520E48E3.6080703@redhat.com>
References: <1376558891-26221-1-git-send-email-amwang@redhat.com> <1376558891-26221-2-git-send-email-amwang@redhat.com> <520E461B.8040406@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Thomas Backlund <tmb@mageia.org>, libc-alpha@sourceware.org,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Andreas Jaeger <aj@suse.com>
Return-path: <libc-alpha-return-42012-glibc-alpha=m.gmane.org@sourceware.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-##L=##H@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
In-Reply-To: <520E461B.8040406@suse.com>
List-Id: netdev.vger.kernel.org

On 08/16/2013 11:32 AM, Andreas Jaeger wrote:
> On 08/15/2013 11:28 AM, Cong Wang wrote:
>> From: Carlos O'Donell <carlos@redhat.com>
>>
>> - Synchronize linux's `include/uapi/linux/in6.h' 
>>   with glibc's `inet/netinet/in.h'.
>> - Synchronize glibc's `inet/netinet/in.h with linux's
>>   `include/uapi/linux/in6.h'.
>> - Allow including the headers in either other.
>> - First header included defines the structures and macros.
> 
> Let me first say that I really love where this is going and would love
> to see more of this work.

The plan would be to eventually tackle more of the conflicting headers
in a uniform way.

> Will this work with older kernels as well? Meaning: Can I compile
> today's user land programs with a new glibc and Kernel 3.10? My reading
> of the patch assumes it does but I would like to hear that you tested it.

You can indeed take a new glibc, and a new kernel, and old programs
that previously failed to compile will now work. The ABI is maintained
and the headers coordinate.

I did not test this explicitly except through the small test case
I wrote which permutes inclusion order and the use of various
structures defined in the headers.

The only quibble one could have is with Linux. In that if you 
include the Linux headers first you will get more definitions than
required by POSIX e.g. s6_addr16 and s6_add32. However as I note
in the comment this is not a violation of POSIX since POSIX says 
"at least the following member" and that holds true.
 
> The patch itself looks fine, thanks,

Thanks for reviewing.

If the kernel patches get accepted I will check these into
glibc 2.19 for Cong.

Cheers,
Carlos.
