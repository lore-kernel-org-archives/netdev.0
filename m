From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH iproute2] ip: add support for more MPLS labels
Date: Tue, 16 May 2017 08:21:49 -0700
Message-ID: <0bbdf1f7-9761-a135-65c4-41f72601a73b@gmail.com>
References: <20170514012702.1083-1-dsahern@gmail.com>
 <20170516083224.GC15081@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34185 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751832AbdEPPVx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 11:21:53 -0400
Received: by mail-pg0-f67.google.com with SMTP id u187so21756417pgb.1
        for <netdev@vger.kernel.org>; Tue, 16 May 2017 08:21:53 -0700 (PDT)
In-Reply-To: <20170516083224.GC15081@vergenet.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/16/17 1:32 AM, Simon Horman wrote:
>> diff --git a/lib/mpls_pton.c b/lib/mpls_pton.c
>> index bd448cfcf14a..6d2e6a69436a 100644
>> --- a/lib/mpls_pton.c
>> +++ b/lib/mpls_pton.c
>> @@ -7,12 +7,13 @@
>>  #include "utils.h"
>>  
>>  
>> -static int mpls_pton1(const char *name, struct mpls_label *addr)
>> +static int mpls_pton1(const char *name, struct mpls_label *addr,
>> +		      unsigned int maxlabels)
>>  {
>>  	char *endp;
>>  	unsigned count;
>>  
>> -	for (count = 0; count < MPLS_MAX_LABELS; count++) {
>> +	for (count = 0; count < maxlabels; count++) {
>>  		unsigned long label;
>>  
>>  		label = strtoul(name, &endp, 0);
>> @@ -37,17 +38,19 @@ static int mpls_pton1(const char *name, struct mpls_label *addr)
>>  		addr += 1;
>>  	}
>>  	/* The address was too long */
>> +	fprintf(stderr, "Error: too many labels.\n");
>>  	return 0;
>>  }
>>  
>> -int mpls_pton(int af, const char *src, void *addr)
>> +int mpls_pton(int af, const char *src, void *addr, size_t alen)
>>  {
>> +	unsigned int maxlabels = alen / sizeof(struct mpls_label);
> 
> Could ARRAY_SIZE be used?
> 
> Also, I know its only calculated twice, but might it be nicer to
> provide a function or macro to do so? It seems like an ugly thing
> to open code.

I did it this way with intention -- to mpls_pton addr is just a buffer
of a given length. mpls_pton converts the alen into the number of labels
that the buffer can hold and passes that max to mpls_pton1 to do the
heavy lifting.
