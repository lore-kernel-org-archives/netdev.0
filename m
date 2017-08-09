From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH v2 iproute2] lib: Dump ext-ack string by default
Date: Wed, 9 Aug 2017 08:03:24 -0600
Message-ID: <602fa731-bc27-9748-2b7a-48274be529d9@gmail.com>
References: <1502202614-389-1-git-send-email-dsahern@gmail.com>
 <9bc620b6-cd6e-a65e-7079-bb4d757312c4@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Girish Moodalbail <girish.moodalbail@oracle.com>,
        netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:36291 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752461AbdHIODY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 10:03:24 -0400
Received: by mail-pg0-f54.google.com with SMTP id v77so28439506pgb.3
        for <netdev@vger.kernel.org>; Wed, 09 Aug 2017 07:03:24 -0700 (PDT)
In-Reply-To: <9bc620b6-cd6e-a65e-7079-bb4d757312c4@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/9/17 1:38 AM, Girish Moodalbail wrote:
>> @@ -99,7 +95,16 @@ static int nl_dump_ext_err(const struct nlmsghdr
>> *nlh, nl_ext_ack_fn_t errfn)
>>               err_nlh = &err->msg;
>>       }
>>   -    return errfn(errmsg, off, err_nlh);
>> +    if (errfn)
>> +        return errfn(errmsg, off, err_nlh);
>> +
>> +    if (errmsg) {
>> +        fprintf(stderr, "Error: %s\n", errmsg);
> 
> Should the above output end with a period '.'? All the error messages in
> the Kernel are statements without a terminating period, so the output

no guarantee of that, but iproute2 could check for it and add it.
