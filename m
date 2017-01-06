From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 2/3] ip vrf: Improve cgroup2 error messages
Date: Fri, 6 Jan 2017 08:05:57 -0700
Message-ID: <2cf5a45c-35ed-fe78-1e2b-18e93706b75e@cumulusnetworks.com>
References: <1483662143-15242-1-git-send-email-dsa@cumulusnetworks.com>
 <1483662143-15242-3-git-send-email-dsa@cumulusnetworks.com>
 <f9858cd0-277b-02cd-35dc-ffc24862f736@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:34100 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752571AbdAFPHL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 10:07:11 -0500
Received: by mail-pg0-f43.google.com with SMTP id 14so8090846pgg.1
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2017 07:05:59 -0800 (PST)
In-Reply-To: <f9858cd0-277b-02cd-35dc-ffc24862f736@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> @@ -80,13 +80,21 @@ char *find_cgroup2_mount(void)
>>
>>      if (mount("none", mnt, CGROUP2_FS_NAME, 0, NULL)) {
>>          /* EBUSY means already mounted */
>> -        if (errno != EBUSY) {
>> +        if (errno == EBUSY)
>> +            goto out;
>> +
>> +        if (errno == ENODEV) {
>>              fprintf(stderr,
>>                  "Failed to mount cgroup2. Are CGROUPS enabled in your kernel?\n");
>> -            free(mnt);
>> -            return NULL;
>> +        } else {
>> +            fprintf(stderr,
>> +                "Failed to mount cgroup2: %s\n",
>> +                strerror(errno));
>>          }
> 
>    How about a *switch* instead?

I did consider it. Did not make the code simpler or easier to read.
