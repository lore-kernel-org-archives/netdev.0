From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 binutils] Add BPF support to binutils...
Date: Mon, 01 May 2017 23:03:23 -0400 (EDT)
Message-ID: <20170501.230323.816591707269395321.davem@davemloft.net>
References: <76ed19a7-add3-0642-4298-9402c7ff0be8@fb.com>
        <20170430.142104.1845572453793505873.davem@davemloft.net>
        <b96ef138-9862-5091-9041-76516f852e48@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, aconole@bytheb.org, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41322 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750853AbdEBDDZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 23:03:25 -0400
In-Reply-To: <b96ef138-9862-5091-9041-76516f852e48@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Mon, 1 May 2017 19:49:21 -0700

> On 4/30/17 11:21 AM, David Miller wrote:
>> built with:
>>
>> 	clang -O2 -target bpfel -g -c x.c -o x.o
>>
>> readelf can see it just fine:
>>
>> [davem@localhost binutils]$ ./readelf --debug-dump=loc ./xel.o
>> Contents of the .debug_loc section:
>>
>>     Offset   Begin            End              Expression
>>     00000000 0000000000000000 0000000000000010 (DW_OP_reg1 (r1))
>>     00000013 <End of list>
>>     00000023 0000000000000010 0000000000000020 (DW_OP_constu:
>>     590618314553; DW_OP_stack_value)
>>     0000003d 0000000000000020 0000000000000030 (DW_OP_reg1 (r1))
>>     00000050 <End of list>
>>
>> But with big-endian:
>>
>> [davem@localhost binutils]$ ./readelf --debug-dump=loc ./xeb.o
>> readelf: Warning: Invalid pointer size (0) in compunit header, using 4
>> instead
>> readelf: Warning: Bogus end-of-siblings marker detected at offset 27
>> in .debug_info section
>> readelf: Warning: Bogus end-of-siblings marker detected at offset 28
>> in .debug_info section
>> readelf: Warning: DIE at offset 0x29 refers to abbreviation number 48
>> which does not exist
>> readelf: Warning: Unable to load/parse the .debug_info section, so
>> cannot interpret the .debug_loc section.
> 
> yeah. clang emitted dwarf for big-endian is broken.
> This dwarf stuff is too complicated for normal human beings.
> The tight packing making debugging it quite painful.

But doesn't the CLANG DWARF2 emission code look at the target
endianness?
