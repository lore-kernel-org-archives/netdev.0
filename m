From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH v3 3/6] bpf: add BPF_PROG_ATTACH and BPF_PROG_DETACH
 commands
Date: Mon, 5 Sep 2016 17:40:09 +0200
Message-ID: <4c7dbf97-4241-0ea2-518c-7e26faa0b059@zonque.org>
References: <1472241532-11682-1-git-send-email-daniel@zonque.org>
 <1472241532-11682-4-git-send-email-daniel@zonque.org>
 <20160827000819.GB29480@ast-mbp.thefacebook.com>
 <4799c1ce-4cb6-0148-26ce-8b6a8ac2a0eb@zonque.org>
 <063D6719AE5E284EB5DD2968C1650D6DB00F4930@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "htejun@fb.com" <htejun@fb.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "ast@fb.com" <ast@fb.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "kafai@fb.com" <kafai@fb.com>, "fw@strlen.de" <fw@strlen.de>,
        "pablo@netfilter.org" <pablo@netfilter.org>,
        "harald@redhat.com" <harald@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "sargun@sargun.me" <sargun@sargun.me>
To: David Laight <David.Laight@ACULAB.COM>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:58104 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932557AbcIEPkN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 11:40:13 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB00F4930@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/05/2016 05:30 PM, David Laight wrote:
> From: Daniel Mack
>>>> +
>>>> +	struct { /* anonymous struct used by BPF_PROG_ATTACH/DETACH commands */
>>>> +		__u32		target_fd;	/* container object to attach to */
>>>> +		__u32		attach_bpf_fd;	/* eBPF program to attach */
>>>> +		__u32		attach_type;	/* BPF_ATTACH_TYPE_* */
>>>> +		__u64		attach_flags;
>>>> +	};
>>>
>>> there is a 4 byte hole in this struct. Can we pack it differently?
>>
>> Okay - I swapped "type" and "flags" to repair this.
> 
> That just moves the pad to the end of the structure.
> Still likely to cause a problem for 32bit apps on a 64bit kernel.

What kind of problem do you have in mind? Again, this is embedded in a
union of much bigger total size, and the API is not used in any kind of
hot-path.

> If you can't think of any flags, why 64 of them?

I can't think of them right now, but this is about defining an API that
can be used in other context as well. Also, it doesn't matter at all,
they don't harm. IMO, it's just better to have them right away than to
do a binary compat dance once someone needs them.


Thanks,
Daniel
