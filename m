From: Rick Jones <rick.jones2@hp.com>
Subject: vethpair creation performance, 3.14 versus 4.2.0
Date: Mon, 31 Aug 2015 12:48:04 -0700
Message-ID: <55E4AF74.7030107@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t2354.austin.hp.com ([15.217.128.53]:58748 "EHLO
	g2t2354.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752716AbbHaTsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 15:48:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/29/2015 10:59 PM, Raghavendra K T wrote:
 > Please note that similar overhead was also reported while creating
 > veth pairs  https://lkml.org/lkml/2013/3/19/556


That got me curious, so I took the veth pair creation script from there, 
and started running it out to 10K pairs, comparing a 3.14.44 kernel with 
a 4.2.0-rc4+ from net-next and then net-next after pulling to get the 
snmp stat aggregation perf change (4.2.0-rc8+).

Indeed, the 4.2.0-rc8+ kernel with the change was faster than the 
4.2.0-rc4+ kernel without it, but both were slower than the 3.14.44 kernel.

I've put a spreadsheet with the results at:

ftp://ftp.netperf.org/vethpair/vethpair_compare.ods

A perf top for the 4.20-rc8+ kernel from the net-next tree looks like 
this out around 10K pairs:

    PerfTop:   11155 irqs/sec  kernel:94.2%  exact:  0.0% [4000Hz 
cycles],  (all, 32 CPUs)
-------------------------------------------------------------------------------

     23.44%  [kernel]       [k] vsscanf
      7.32%  [kernel]       [k] mutex_spin_on_owner.isra.4
      5.63%  [kernel]       [k] __memcpy
      5.27%  [kernel]       [k] __dev_alloc_name
      3.46%  [kernel]       [k] format_decode
      3.44%  [kernel]       [k] vsnprintf
      3.16%  [kernel]       [k] acpi_os_write_port
      2.71%  [kernel]       [k] number.isra.13
      1.50%  [kernel]       [k] strncmp
      1.21%  [kernel]       [k] _parse_integer
      0.93%  [kernel]       [k] filemap_map_pages
      0.82%  [kernel]       [k] put_dec_trunc8
      0.82%  [kernel]       [k] unmap_single_vma
      0.78%  [kernel]       [k] native_queued_spin_lock_slowpath
      0.71%  [kernel]       [k] menu_select
      0.65%  [kernel]       [k] clear_page
      0.64%  [kernel]       [k] _raw_spin_lock
      0.62%  [kernel]       [k] page_fault
      0.60%  [kernel]       [k] find_busiest_group
      0.53%  [kernel]       [k] snprintf
      0.52%  [kernel]       [k] int_sqrt
      0.46%  [kernel]       [k] simple_strtoull
      0.44%  [kernel]       [k] page_remove_rmap

My attempts to get a call-graph have been met with very limited success. 
  Even though I've installed the dbg package from "make deb-pkg" the 
symbol resolution doesn't seem to be working.

happy benchmarking,

rick jones
