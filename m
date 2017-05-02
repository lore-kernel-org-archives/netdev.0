From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH v3 binutils] Add BPF support to binutils...
Date: Mon, 1 May 2017 19:49:21 -0700
Message-ID: <b96ef138-9862-5091-9041-76516f852e48@fb.com>
References: <20170429.222450.1300920007783667009.davem@davemloft.net>
 <20170429.223759.1262491011130998405.davem@davemloft.net>
 <76ed19a7-add3-0642-4298-9402c7ff0be8@fb.com>
 <20170430.142104.1845572453793505873.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <aconole@bytheb.org>,
        <netdev@vger.kernel.org>, <xdp-newbies@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:45286 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750830AbdEBCuB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 22:50:01 -0400
In-Reply-To: <20170430.142104.1845572453793505873.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/30/17 11:21 AM, David Miller wrote:
> built with:
>
> 	clang -O2 -target bpfel -g -c x.c -o x.o
>
> readelf can see it just fine:
>
> [davem@localhost binutils]$ ./readelf --debug-dump=loc ./xel.o
> Contents of the .debug_loc section:
>
>     Offset   Begin            End              Expression
>     00000000 0000000000000000 0000000000000010 (DW_OP_reg1 (r1))
>     00000013 <End of list>
>     00000023 0000000000000010 0000000000000020 (DW_OP_constu: 590618314553; DW_OP_stack_value)
>     0000003d 0000000000000020 0000000000000030 (DW_OP_reg1 (r1))
>     00000050 <End of list>
>
> But with big-endian:
>
> [davem@localhost binutils]$ ./readelf --debug-dump=loc ./xeb.o
> readelf: Warning: Invalid pointer size (0) in compunit header, using 4 instead
> readelf: Warning: Bogus end-of-siblings marker detected at offset 27 in .debug_info section
> readelf: Warning: Bogus end-of-siblings marker detected at offset 28 in .debug_info section
> readelf: Warning: DIE at offset 0x29 refers to abbreviation number 48 which does not exist
> readelf: Warning: Unable to load/parse the .debug_info section, so cannot interpret the .debug_loc section.

yeah. clang emitted dwarf for big-endian is broken.
This dwarf stuff is too complicated for normal human beings.
The tight packing making debugging it quite painful.
