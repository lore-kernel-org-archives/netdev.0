From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH] net: introduce SO_BPF_EXTENSIONS
Date: Thu, 16 Jan 2014 19:34:14 +0100
Message-ID: <52D82626.5060701@redhat.com>
References: <1389888898-31744-1-git-send-email-msekleta@redhat.com> <52D80BCA.7030400@redhat.com> <20140116172631.GA5206@loki.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michael Kerrisk <mtk.manpages@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Michal Sekletar <msekleta@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56026 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751502AbaAPSeW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 13:34:22 -0500
In-Reply-To: <20140116172631.GA5206@loki.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/16/2014 06:26 PM, Michal Sekletar wrote:
> On Thu, Jan 16, 2014 at 05:41:46PM +0100, Daniel Borkmann wrote:
>> On 01/16/2014 05:14 PM, Michal Sekletar wrote:
>>> userspace packet capturing libraries (e.g. libpcap) don't have a way how to find
>>> out which BPF extensions are supported by the kernel, except compiling a filter
>>> which uses extensions and trying to apply filter to the socket. This is very
>>> inconvenient.
>>>
>>> Therefore this commit introduces new option which can be used as an argument for
>>> getsockopt() and allows one to obtain information about which BPF extensions are
>>> supported by the kernel.
>>>
>>> On Tue, Dec 10, 2013 at 1:25 AM, David Miller <davem@davemloft.net> wrote:
>>>
>>>> And therefore, you do not need to define any actual bits yet. The
>>>> socket option will for now just return "0", and that will mean that
>>>> all the extensions Linux implements currently are presnet.
>>>
>>> Signed-off-by: Michal Sekletar <msekleta@redhat.com>
>>> Cc: Michael Kerrisk <mtk.manpages@gmail.com>
>>> Cc: Daniel Borkmann <dborkman@redhat.com>
>>> Cc: David Miller <davem@davemloft.net>
>>> ---
>>>   arch/alpha/include/uapi/asm/socket.h   | 2 ++
>>>   arch/avr32/include/uapi/asm/socket.h   | 2 ++
>>>   arch/cris/include/uapi/asm/socket.h    | 2 ++
>>>   arch/frv/include/uapi/asm/socket.h     | 2 ++
>>>   arch/ia64/include/uapi/asm/socket.h    | 2 ++
>>>   arch/m32r/include/uapi/asm/socket.h    | 2 ++
>>>   arch/mips/include/uapi/asm/socket.h    | 2 ++
>>>   arch/mn10300/include/uapi/asm/socket.h | 2 ++
>>>   arch/parisc/include/uapi/asm/socket.h  | 2 ++
>>>   arch/powerpc/include/uapi/asm/socket.h | 2 ++
>>>   arch/s390/include/uapi/asm/socket.h    | 2 ++
>>>   arch/sparc/include/uapi/asm/socket.h   | 2 ++
>>>   arch/xtensa/include/uapi/asm/socket.h  | 2 ++
>>>   include/net/sock.h                     | 5 +++++
>>>   include/uapi/asm-generic/socket.h      | 2 ++
>>>   net/core/sock.c                        | 4 ++++
>>>   16 files changed, 37 insertions(+)
>>>
>> ...
>>> --- a/include/net/sock.h
>>> +++ b/include/net/sock.h
>>> @@ -2292,4 +2292,9 @@ extern int sysctl_optmem_max;
>>>   extern __u32 sysctl_wmem_default;
>>>   extern __u32 sysctl_rmem_default;
>>>
>>> +static inline int bpf_get_extensions(void)
>>> +{
>>> +	return 0;
>>> +}
>>> +
>>
>> This should rather be in: include/linux/filter.h
>
> Yes, having that function there makes more sense.
>
>>
>> And then, maybe be renamed into something like bpf_tell_extensions()
>> for example, but that's just nit.
>
> Renamed.
>
>>
>> Also, please add a comment, saying if people add new extensions, they
>> need to enumerate them within this function from now on so that user
>> space who enquires for that can be made aware of.
>
> Let me know if even more explanatory comment is desired.

I think that looks good.

>> Still, grepping through latest libpcap sources, tells me, so far over
>> the years they have included SKF_AD_PROTOCOL and SKF_AD_PKTTYPE, wow!
>>
>> That's very disappointing, so I have high hopes with this getsockopt().
>>
>> ;)
>>
>> Thanks,
>
> Thank you for the review. Btw, what do you think about define for parisc? I am

Yes, saw that in the patch and had similar thoughts.

> not sure I grok 0x4048 for SO_MAX_PACING_RATE and hence not sure about 0x4029
> for SO_BPF_EXTENSIONS.

Hmm, maybe typo; SO_MAX_PACING_RATE should have been a 0x4028 ?
