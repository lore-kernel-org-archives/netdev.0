From: Grant Zhang <gzhang@fastly.com>
Subject: Re: Recurring trace from tcp_fragment()
Date: Thu, 04 Jun 2015 13:10:26 -0700
Message-ID: <5570B0B2.5080908@fastly.com>
References: <CFCC0DCC-4080-4195-9BA9-0860D9701805@fastly.com> <CADVnQyngTDVYMhmQq=pjS3LrdQ+HXyizujiOkmgXxTjQ0QKH8A@mail.gmail.com> <5E30A40E-EC6C-4D37-AB49-04BF40EEFBFC@fastly.com> <CADVnQy=rwKG_ddduixcee1D4HaaSBBk=X=2Htmdow0k6Cbxhzg@mail.gmail.com> <904FADEB-C1EB-4384-BA47-0EB0273AFB71@fastly.com> <CADVnQymCSGyyOqdO2HOap+_6zsfy99-3CbgxnQTfGakRYNoteQ@mail.gmail.com> <55707E38.4090506@fastly.com> <20150604193838.GA2951343@devbig242.prn2.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Kernel Team <kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:33588 "EHLO
	mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103AbbFDUK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 16:10:29 -0400
Received: by qkhg32 with SMTP id g32so29946854qkh.0
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 13:10:28 -0700 (PDT)
In-Reply-To: <20150604193838.GA2951343@devbig242.prn2.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Martin,

Thank you! My net.ipv4.tcp_mtu_probing is 1. After turning it off, the 
WARN_ON stack is gone.

Could you elaborate a bit on why this setting relates to the WARN_ON 
trace? And what are the pros/cons for disabling mtu_probing?

Thanks,

Grant

On 6/4/15 12:38 PM, Martin KaFai Lau wrote:
> Hi Grant,
>
> On Thu, Jun 04, 2015 at 09:35:04AM -0700, Grant Zhang wrote:
>> Hi Neal,
>>
>> Unfortunately with the patch we still see the same stack trace.
>> Attached is the TcpExtTCPSACKReneging with the patch, captured with
>> 60 seconds interval. Its value is incremented at an similar speed as
>> before, about 30/minute.
>>
>> If you want to collect any other data, please feel free to let me know.
>>
>
> We are also seeing similar WARN_ON stack in our kernel 4.0 testing.
>
> What is your net.ipv4.tcp_mtu_probing setting?  I am currently testing some
> code changes and waiting for some more data.  If it is 1 or 2,
> can you help to check whether turning it off (by setting it to 0) will stop the
> WARN_ON or not in your environment?  Note that after setting it to 0, you
> may need to wait for a while (like a few mins) for the existing probing
> activities to quiet down before observing the WARN_ON output.
>
> Thanks,
> --Martin
>
