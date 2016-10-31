From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v2 net-next 1/5] bpf: Refactor cgroups code in prep for
 new type
Date: Mon, 31 Oct 2016 11:05:04 -0600
Message-ID: <44b37825-d001-c708-963f-cbdedb559710@cumulusnetworks.com>
References: <1477529922-4806-1-git-send-email-dsa@cumulusnetworks.com>
 <1477529922-4806-2-git-send-email-dsa@cumulusnetworks.com>
 <20161031.125801.874510216543796824.davem@davemloft.net>
 <542e0d3e-2f57-96f9-1da1-b71e2c970395@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        maheshb@google.com, tgraf@suug.ch
To: Daniel Mack <daniel@zonque.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:32966 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S944427AbcJaRFH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 13:05:07 -0400
Received: by mail-pf0-f169.google.com with SMTP id d2so4503269pfd.0
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 10:05:06 -0700 (PDT)
In-Reply-To: <542e0d3e-2f57-96f9-1da1-b71e2c970395@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/16 11:00 AM, Daniel Mack wrote:
> On 10/31/2016 05:58 PM, David Miller wrote:
>> From: David Ahern <dsa@cumulusnetworks.com>
>> Date: Wed, 26 Oct 2016 17:58:38 -0700
>>
>>> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
>>> index 6b62ee9a2f78..73da296c2125 100644
>>> --- a/include/uapi/linux/bpf.h
>>> +++ b/include/uapi/linux/bpf.h
>>> @@ -98,7 +98,7 @@ enum bpf_prog_type {
>>>  	BPF_PROG_TYPE_TRACEPOINT,
>>>  	BPF_PROG_TYPE_XDP,
>>>  	BPF_PROG_TYPE_PERF_EVENT,
>>> -	BPF_PROG_TYPE_CGROUP_SKB,
>>> +	BPF_PROG_TYPE_CGROUP,
>>>  };
>>>  
>>>  enum bpf_attach_type {
>>
>> If we do this then the cgroup-bpf series should use this value rather than
>> changing it after-the-fact in your series here.
>>
> 
> Yeah, I'm confused too. I changed that name in my v7 from
> BPF_PROG_TYPE_CGROUP_SOCK to BPF_PROG_TYPE_CGROUP_SKB on David's (Ahern)
> request. Why is it now renamed again?

Thomas pushed back on adding another program type in favor of using subtypes. So this makes the program type generic to CGROUP and patch 2 in this v2 set added Mickaël's subtype patch with the socket mangling done that way in patch 3.
