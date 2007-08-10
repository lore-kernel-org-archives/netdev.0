From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: 2.6.23-rc2-mm2 -- conntrack divide error
Date: Fri, 10 Aug 2007 22:22:20 +0200
Message-ID: <46BCC8FC.8020804@gmail.com>
References: <20070809224254.11f42716.akpm@linux-foundation.org>	 <a8e1da0708100118r779068i64ffdc11e452be9b@mail.gmail.com>	 <20070810013210.1b2f121c.akpm@linux-foundation.org>	 <a8e1da0708100137t48c5c673vf0c98fb5f0cd058b@mail.gmail.com> <a8e1da0708100252g5597da63j9cb665ade26f7654@mail.gmail.com> <46BC49C3.6020100@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Dave Young <hidave.darkstar@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gabriel C <nix.or.die@googlemail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965444AbXHJUVz@vger.kernel.org>
In-Reply-To: <46BC49C3.6020100@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gabriel C napsal(a):
> Dave Young wrote:
>>> On 8/10/07, Dave Young <hidave.darkstar@gmail.com> wrote:
>>>> On 8/10/07, Andrew Morton <akpm@linux-foundation.org> wrote:
>>>> On Fri, 10 Aug 2007 16:18:38 +0800 "Dave Young" <hidave.darkstar@gmail.com> wrote:
>>>>
>>>>> Hi,
>>>>> 2.6.23-rc2-mm2:
>>>>> config with CONFIG_NF_CONNTRACK_AMANDA=y
>>>>> boot  oops:
>>>>>
>>>>> hand copyed :
>>>>> the EIP: helper_hash
>>>>>
>>>>> backtrace:
>>>>> do_basic_setup
>>>>> ...
>>>>> nf_conntrack_amanda_init
>>>>> error_code
>>>>> do_vivide_error
>>>>> ...
>>>>>
>>>> cc netdev
>>>>
>>>> please send config
>>>>
>>>> presumably nf_ct_helper_hsize is zero

I think so. 2.6.23-rc2-mm1 seemed be OK.

>>>>
>>>> I'd have thought that the same bug would be present in mainline - there's
>>>> nothing in git-net.patch.
>>>>
>>>> (hunts around, discovers that there's a net-2.6.24 tree now.  Bah)
>>>>
>>> MY config file for test:
>>> -----cut---
>> Hi,
>> config the CONFIG_NF_CONNTRACK_AMANDA=m, reboot , still oops, but this
>> time the point is nf_conntrack_ftp_init, (I doubt the
>> nf_conntrack_core is not initialized.)
>>
>> boot with vga_ask and select 80x60, copyed more infomations:
>> ---------pre oops:-----------
>> sysctl table check failed: /net/netfilter/nf_conntrack_generic_timeout
>> .3.19.13 Missing strategy
>> ...
>> nf_conntrack_14_proto_sctp4 protocol register failed
>> ...
>> ---------oops:----------------
>> divide error: 0000 [#1] SMP
>> EIP: 0060: [<c088477b>] EFLAGS 00010246
>> Process swapper
>> ...
>> nf_conntrack_ftp_init
>> ...
>>
>> Code: <...>
>> EIP <...> helper_hash +0x1b/0x24
> 
> Does not Oops here but is broken.

My $0.02:
http://www.fi.muni.cz/~xslaby/sklad/panics/nf_oops.png
http://www.fi.muni.cz/~xslaby/sklad/panics/nf_oops.config

-- 
Jiri Slaby (jirislaby@gmail.com)
Faculty of Informatics, Masaryk University
