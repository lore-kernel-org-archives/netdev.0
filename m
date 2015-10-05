From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 3/5] net: Refactor path selection in
 __ip_route_output_key
Date: Mon, 5 Oct 2015 08:08:26 -0600
Message-ID: <5612845A.9090203@cumulusnetworks.com>
References: <1443713247-11230-4-git-send-email-dsa@cumulusnetworks.com>
 <201510021431.hGNWKbMp%fengguang.wu@intel.com>
 <20151005.063836.1612675139838377064.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org, dsahern@gmail.com,
	linux-mips@linux-mips.org
To: David Miller <davem@davemloft.net>, lkp@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:33236 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569AbbJEOI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 10:08:29 -0400
Received: by pacex6 with SMTP id ex6so178463310pac.0
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 07:08:28 -0700 (PDT)
In-Reply-To: <20151005.063836.1612675139838377064.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/5/15 7:38 AM, David Miller wrote:
> From: kbuild test robot <lkp@intel.com>
> Date: Fri, 2 Oct 2015 14:20:30 +0800
>
>> Hi David,
>>
>> [auto build test results on next-20151001 -- if it's inappropriate base, please ignore]
>>
>> config: mips-nlm_xlp_defconfig (attached as .config)
>> reproduce:
>>          wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>>          chmod +x ~/bin/make.cross
>>          # save the attached .config to linux build tree
>>          make.cross ARCH=mips
>>
>> All warnings (new ones prefixed by >>):
>>
>>>> mips-linux-gnu-ld: net/ipv4/.tmp_fib_semantics.o: warning: Inconsistent ISA between e_flags and .MIPS.abiflags
>
> Frankly this looks like a build infrastructure or tools bug to me.
>

That's pretty much what I got back from Joshua on the linux-mips mailing 
list when I inquired about why a code move generates the warning:

"Dunno if your patch generated the message per-say, but it seems some 
platforms in the MIPS tree cause this message to appear. I.e., IP27 or 
IP32 builds (or IP30 out-of-tree) don't emit this error, but building 
IP28 systems in-tree will cause it to appear quite a bit.

The message itself, I believe is complaining that the stated CPU ISA 
(mips1 ... mips4, mips32r2, r10000, etc) in one of the sections 
(e.g.,.MIPS.abiflags) doesn't match the equivalent ISA value in the 
other section (e.g., e_flags). I haven't seen any harmful side effects 
of it myself. Seems to be more of a warning than anything else, and as 
long as the ISA matches a supported CPU (e.g., r10000 is compatible with 
mips4), it can be ignored. It does clutter up the build, though."
