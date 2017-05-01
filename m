From: Aaron Conole <aconole@bytheb.org>
Subject: Re: [PATCH v4 binutils] Add BPF support to binutils...
Date: Mon, 01 May 2017 14:39:39 -0400
Message-ID: <f7t37coxvys.fsf@redhat.com>
References: <20170430.120750.651845251226226775.davem@davemloft.net>
        <f7ttw541ohz.fsf@redhat.com>
        <20170501.135202.2175412915689459473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ast@fb.com, daniel@iogearbox.net, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:35943 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750866AbdEASjn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 14:39:43 -0400
Received: by mail-qt0-f195.google.com with SMTP id t52so17373886qtb.3
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 11:39:43 -0700 (PDT)
In-Reply-To: <20170501.135202.2175412915689459473.davem@davemloft.net> (David
        Miller's message of "Mon, 01 May 2017 13:52:02 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Aaron Conole <aconole@bytheb.org>
> Date: Mon, 01 May 2017 13:22:00 -0400
>
>> x86-64:
>>   Running /home/aconole/git/binutils-gdb/gas/testsuite/gas/bpf/bpf.exp ...
>>   FAIL: jump
>>   FAIL: call
>>   FAIL: imm64a
>>   Running /home/aconole/git/binutils-gdb/gas/testsuite/gas/cfi/cfi.exp ...
>
> I cannot reproduce this, can you show what it says in the:
>
> 	/home/aconole/git/binutils-gdb/gas/testsuite/gas.log
>
> file near the "FAIL" cases?

Executing on host: sh -c {/home/aconole/git/binutils-gdb/gas/testsuite/../../binutils/objdump  -dr dump.o >dump.out 2>gas.stderr}  /dev/null  (timeout = 300)
spawn [open ...]
regexp_diff match failure
regexp "^ 108:	95 00 00 00 00 00 00 00 	exit$"
line   " 108:	95 00 00 00 00 00 00 00 	exit	"
FAIL: jump


Same style of error for call and imm64a.  After reverting and then
re-applying your patch, the FAILs all go away, so I must have broken
these files somehow.  Sorry for the false alarm.

-Aaron
