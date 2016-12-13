From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH V2 00/22] Broadcom RoCE Driver (bnxt_re)
Date: Tue, 13 Dec 2016 08:54:46 +0200
Message-ID: <ca6a2493-187b-e8d2-972c-51c39e971a7d@mellanox.com>
References: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <dledford@redhat.com>, <linux-rdma@vger.kernel.org>,
        <netdev@vger.kernel.org>
To: Selvin Xavier <selvin.xavier@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0059.outbound.protection.outlook.com ([104.47.2.59]:18800
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752445AbcLMJ2m (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Dec 2016 04:28:42 -0500
In-Reply-To: <1481266096-23331-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/9/2016 8:47 AM, Selvin Xavier wrote:
> This series introduces the RoCE driver for the Broadcom
> NetXtreme-E 10/25/40/50 gigabit RoCE HCAs.
> This driver is dependent on the bnxt_en NIC driver and is
> based on the bnxt_re branch in Doug's repository. bnxt_en changes
> required for this patch series is already available in this branch.
>
> I am preparing a git repository with these changes as per Jason's
> comment and will share the details later today.
>
> v1-> v2:
>    * The license text in each file updated to reflect Dual license.
>    * Makefile and Kconfig changes are pushed to the last patch
>    * Moved bnxt_re_uverbs_abi.h to include/uapi/rdma folder
>    * Remove duplicate structure definitions from bnxt_re_hsi.h as
>      it is available in the corresponding bnxt_en header file (bnxt_hsi.h)
>    * Removed some unused code reported during code review.
>    * Fixed few sparse warnings
>
> Doug, Please review and consider applying this to linux-rdma repository.

Hi,

I made some quick on-the-surface static checkers etc rub on the new 
driver (Doug, I used the bits in your github bnxt_re branch), there are 
bunch (tons...) of smatch [1] and sparse [2]complaints along with few 
checkpatch [3] things too.  So... addressing them before this goes upstream?

BTW net-next's drivers/net/ethernet/broadcom/bnxt (where you put the pre 
patches for the RDMA driver) is pretty much clean of that

Or.

[1] smatch

CHECK   drivers/infiniband/hw/bnxt_re/bnxt_re_main.c
   CHECK   drivers/infiniband/hw/bnxt_re/bnxt_re_ib_verbs.c
   CHECK   drivers/infiniband/hw/bnxt_re/bnxt_re_debugfs.c
   CHECK   drivers/infiniband/hw/bnxt_re/bnxt_qplib_res.c
   CHECK   drivers/infiniband/hw/bnxt_re/bnxt_qplib_rcfw.c
   CHECK   drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c
   CHECK   drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:185 bnxt_qplib_del_sgid() 
warn: impossible condition '(*sgid_tbl->hw_id + index == -1) => (0-65535 
== (-1))'
drivers/infiniband/hw/bnxt_re/bnxt_qplib_rcfw.c:107 
bnxt_qplib_rcfw_send_message() warn: test_bit() takes a bit number
drivers/infiniband/hw/bnxt_re/bnxt_qplib_rcfw.c:116 
bnxt_qplib_rcfw_send_message() warn: test_bit() takes a bit number
drivers/infiniband/hw/bnxt_re/bnxt_qplib_rcfw.c:148 
bnxt_qplib_rcfw_send_message() error: double lock 'irqsave:flags'
drivers/infiniband/hw/bnxt_re/bnxt_qplib_rcfw.c:204 
bnxt_qplib_rcfw_send_message() error: double unlock 'irqsave:flags'
drivers/infiniband/hw/bnxt_re/bnxt_re_main.c:121 
bnxt_re_unregister_netdev() warn: variable dereferenced before check 
'rdev' (see line 118)
drivers/infiniband/hw/bnxt_re/bnxt_re_main.c:140 
bnxt_re_register_netdev() warn: variable dereferenced before check 
'rdev' (see line 137)
drivers/infiniband/hw/bnxt_re/bnxt_re_main.c:155 bnxt_re_free_msix() 
warn: variable dereferenced before check 'rdev' (see line 152)
drivers/infiniband/hw/bnxt_re/bnxt_re_main.c:173 bnxt_re_request_msix() 
warn: variable dereferenced before check 'rdev' (see line 171)
drivers/infiniband/hw/bnxt_re/bnxt_qplib_res.c:172 
bnxt_qplib_alloc_init_hwq() warn: unsigned '*elements' is never less 
than zero.
drivers/infiniband/hw/bnxt_re/bnxt_qplib_rcfw.c:387 
bnxt_qplib_deinit_rcfw() warn: test_bit() takes a bit number
drivers/infiniband/hw/bnxt_re/bnxt_qplib_res.c:488 
bnxt_qplib_alloc_sgid_tbl() warn: double check that we're allocating 
correct size: 2 vs 4
drivers/infiniband/hw/bnxt_re/bnxt_qplib_res.c:688 
bnxt_qplib_alloc_dpi_tbl() warn: consider using resource_size() here
drivers/infiniband/hw/bnxt_re/bnxt_qplib_rcfw.c:496 
bnxt_qplib_init_rcfw() warn: test_bit() takes a bit number
./include/linux/mm.h:1385 stack_guard_page_end() warn: bitwise AND 
condition is false here
./include/linux/mm.h:1379 vma_growsup() warn: bitwise AND condition is 
false here
drivers/infiniband/hw/bnxt_re/bnxt_re_main.c:522 show_rev() info: 
ignoring unreachable code.
drivers/infiniband/hw/bnxt_re/bnxt_re_main.c:835 bnxt_re_dev_stop() 
warn: was && intended here instead of ||?
drivers/infiniband/hw/bnxt_re/bnxt_re_main.c:1048 bnxt_re_ib_reg() warn: 
curly braces intended?
drivers/infiniband/hw/bnxt_re/bnxt_re_main.c:1050 bnxt_re_ib_reg() warn: 
inconsistent indenting
drivers/infiniband/hw/bnxt_re/bnxt_re_main.c:1190 bnxt_re_task() warn: 
curly braces intended?
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1639 __flush_sq() warn: 
variable dereferenced before check 'budget' (see line 1621)
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1852 
bnxt_qplib_cq_process_res_ud() warn: shift has higher precedence than mask
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1861 
bnxt_qplib_cq_process_res_ud() warn: inconsistent indenting
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:2015 
bnxt_qplib_cq_process_terminal() warn: variable dereferenced before 
check 'budget' (see line 1997)
drivers/infiniband/hw/bnxt_re/bnxt_re_ib_verbs.c:1607 
bnxt_re_build_qp1_send_v2 warn: unused return: size = ib_ud_header_pack()
drivers/infiniband/hw/bnxt_re/bnxt_re_ib_verbs.c:1681 
bnxt_re_build_qp1_shadow_qp_recv() warn: unsigned 'sge.size' is never 
less than zero.
drivers/infiniband/hw/bnxt_re/bnxt_re_ib_verbs.c:2066 
bnxt_re_post_recv_shadow_qp warn: unused return: payload_sz = 
bnxt_re_build_sgl()
drivers/infiniband/hw/bnxt_re/bnxt_re_ib_verbs.c:2242 
bnxt_re_create_cq() warn: variable dereferenced before check 'cq->umem' 
(see line 2192)
drivers/infiniband/hw/bnxt_re/bnxt_re_ib_verbs.c:2456 
bnxt_re_is_loopback_packet() warn: curly braces intended?
drivers/infiniband/hw/bnxt_re/bnxt_re_ib_verbs.c:2512 
bnxt_re_process_raw_qp_pkt_rx() warn: impossible condition '(pkt_type < 
0) => (0-255 < 0)'
drivers/infiniband/hw/bnxt_re/bnxt_re_ib_verbs.c:2578 
bnxt_re_process_raw_qp_pkt_rx warn: unused return: rc = 
bnxt_re_post_send_shadow_qp()
drivers/infiniband/hw/bnxt_re/bnxt_re_ib_verbs.c:2838 bnxt_re_dereg_mr 
warn: unused return: rc = bnxt_qplib_free_fast_reg_page_list()

[2] sparse

  CHECK   drivers/infiniband/hw/bnxt_re/bnxt_re_main.c
   CHECK   drivers/infiniband/hw/bnxt_re/bnxt_re_ib_verbs.c
   CHECK   drivers/infiniband/hw/bnxt_re/bnxt_re_debugfs.c
   CHECK   drivers/infiniband/hw/bnxt_re/bnxt_qplib_res.c
   CHECK   drivers/infiniband/hw/bnxt_re/bnxt_qplib_rcfw.c
   CHECK   drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c
   CHECK   drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:111:33: warning: cast to 
restricted __le32
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:114:30: warning: 
restricted __le32 degrades to integer
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:114:30: warning: cast to 
restricted __le32
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:277:28: warning: incorrect 
type in assignment (different base types)
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:277:28: expected 
restricted __le32 <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:277:28: got restricted 
__be32 [usertype] <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:278:28: warning: incorrect 
type in assignment (different base types)
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:278:28: expected 
restricted __le32 <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:278:28: got restricted 
__be32 [usertype] <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:279:28: warning: incorrect 
type in assignment (different base types)
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:279:28: expected 
restricted __le32 <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:279:28: got restricted 
__be32 [usertype] <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:280:28: warning: incorrect 
type in assignment (different base types)
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:280:28: expected 
restricted __le32 <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:280:28: got restricted 
__be32 [usertype] <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:282:34: warning: incorrect 
type in assignment (different base types)
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:282:34: expected 
restricted __le16 [addressable] [assigned] [usertype] vlan
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:282:34: got restricted 
__le32 [usertype] <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:289:32: warning: incorrect 
type in assignment (different base types)
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:289:32: expected 
restricted __le16 <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:289:32: got restricted 
__be16 [usertype] <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:290:32: warning: incorrect 
type in assignment (different base types)
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:290:32: expected 
restricted __le16 <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:290:32: got restricted 
__be16 [usertype] <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:291:32: warning: incorrect 
type in assignment (different base types)
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:291:32: expected 
restricted __le16 <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:291:32: got restricted 
__be16 [usertype] <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:810:18: warning: incorrect 
type in assignment (different base types)
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:810:18: expected 
restricted __le16 [addressable] [assigned] [usertype] cos0
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:810:18: got unsigned short 
[unsigned] [short] [usertype] <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:811:18: warning: incorrect 
type in assignment (different base types)
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:811:18: expected 
restricted __le16 [addressable] [assigned] [usertype] cos1
drivers/infiniband/hw/bnxt_re/bnxt_qplib_sp.c:811:18: got unsigned short 
[unsigned] [short] [usertype] <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:133:22: warning: 
restricted __le32 degrades to integer
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:136:24: warning: 
restricted __le16 degrades to integer
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:136:24: warning: cast to 
restricted __le16
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:777:25: warning: incorrect 
type in assignment (different base types)
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:777:25: expected 
restricted __le32 [addressable] [assigned] [usertype] modify_mask
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:777:25: got restricted 
__le64 [usertype] <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:822:30: warning: incorrect 
type in assignment (different base types)
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:822:30: expected unsigned 
char [unsigned] [addressable] [assigned] [usertype] path_mtu
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:822:30: got restricted 
__le16 [usertype] <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:953:26: warning: 
restricted __le16 degrades to integer
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:953:26: warning: cast to 
restricted __le16
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:956:26: warning: 
restricted __le16 degrades to integer
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:970:26: warning: cast to 
restricted __le32
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:970:26: warning: cast from 
restricted __le16
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1211:34: warning: invalid 
assignment: +=
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1211:34: left side has 
type int
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1211:34: right side has 
type restricted __le32
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1333:24: warning: 
incorrect type in assignment (different base types)
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1333:24: expected unsigned 
int [unsigned] [usertype] temp32
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1333:24: got restricted 
__le32 [usertype] <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1343:46: warning: 
incorrect type in assignment (different base types)
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1343:46: expected unsigned 
long long [unsigned] [long] [long long] [usertype] <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1343:46: got restricted 
__le64 [usertype] <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1363:24: warning: 
incorrect type in assignment (different base types)
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1363:24: expected unsigned 
int [unsigned] [addressable] [usertype] temp32
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1363:24: got restricted 
__le32 [usertype] <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1533:27: warning: 
incorrect type in assignment (different base types)
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1533:27: expected 
restricted __le32 [addressable] [assigned] [usertype] cq_fco_cnq_id
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1533:27: got restricted 
__le16 [usertype] <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1796:21: warning: 
restricted __le32 degrades to integer
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1796:21: warning: cast to 
restricted __le64
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1849:21: warning: 
restricted __le32 degrades to integer
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1849:21: warning: cast to 
restricted __le64
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1852:39: warning: 
restricted __le32 degrades to integer
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1904:21: warning: 
restricted __le32 degrades to integer
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1904:21: warning: cast to 
restricted __le64
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1917:34: warning: cast to 
restricted __le16
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1917:34: warning: cast 
from restricted __le32
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1015:22: warning: context 
imbalance in 'bnxt_qplib_lock_cqs' - wrong count at exit
drivers/infiniband/hw/bnxt_re/bnxt_qplib_fp.c:1030:28: warning: context 
imbalance in 'bnxt_qplib_unlock_cqs' - unexpected unlock
drivers/infiniband/hw/bnxt_re/bnxt_qplib_res.c:410:72: warning: 
incorrect type in assignment (different base types)
drivers/infiniband/hw/bnxt_re/bnxt_qplib_res.c:410:72: expected unsigned 
long long [unsigned] [long] [long long] [usertype] <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_res.c:410:72: got restricted 
__le64 [usertype] <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_res.c:418:56: warning: 
incorrect type in assignment (different base types)
drivers/infiniband/hw/bnxt_re/bnxt_qplib_res.c:418:56: expected unsigned 
long long [unsigned] [long] [long long] [usertype] <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_res.c:418:56: got restricted 
__le64 [usertype] <noident>
drivers/infiniband/hw/bnxt_re/bnxt_qplib_res.c:729:6: warning: symbol 
'bnxt_qplib_cleanup_pkey_tbl' was not declared. Should it be static?
drivers/infiniband/hw/bnxt_re/bnxt_re_ib_verbs.c:1725:47: warning: 
incorrect type in assignment (different base types)
drivers/infiniband/hw/bnxt_re/bnxt_re_ib_verbs.c:1725:47: expected 
unsigned int [unsigned] [usertype] imm_data_or_inv_key
drivers/infiniband/hw/bnxt_re/bnxt_re_ib_verbs.c:1725:47: got restricted 
__be32 [usertype] imm_data
drivers/infiniband/hw/bnxt_re/bnxt_re_ib_verbs.c:1755:47: warning: 
incorrect type in assignment (different base types)
drivers/infiniband/hw/bnxt_re/bnxt_re_ib_verbs.c:1755:47: expected 
unsigned int [unsigned] [usertype] imm_data_or_inv_key
drivers/infiniband/hw/bnxt_re/bnxt_re_ib_verbs.c:1755:47: got restricted 
__be32 [usertype] imm_data
drivers/infiniband/hw/bnxt_re/bnxt_re_ib_verbs.c:2627:25: warning: 
incorrect type in assignment (different base types)
drivers/infiniband/hw/bnxt_re/bnxt_re_ib_verbs.c:2627:25: expected 
restricted __be32 [usertype] imm_data
drivers/infiniband/hw/bnxt_re/bnxt_re_ib_verbs.c:2627:25: got unsigned 
int [unsigned] [usertype] immdata_or_invrkey
drivers/infiniband/hw/bnxt_re/bnxt_re_ib_verbs.c:2696:41: warning: 
incorrect type in assignment (different base types)
drivers/infiniband/hw/bnxt_re/bnxt_re_ib_verbs.c:2696:41: expected 
restricted __be32 [usertype] imm_data
drivers/infiniband/hw/bnxt_re/bnxt_re_ib_verbs.c:2696:41: got unsigned 
int [unsigned] [usertype] immdata_or_invrkey

[3] checkpatch

CHECK: Macro argument reuse 'req' - possible side-effects?
CHECK: Macro argument reuse 'prod' - possible side-effects?
CHECK: Macro argument reuse 'dma_addr' - possible side-effects?
CHECK: Macro argument reuse 'rdev' - possible side-effects?
CHECK: Please don't use multiple blank lines
CHECK: Alignment should match open parenthesis
CHECK: Alignment should match open parenthesis
CHECK: Alignment should match open parenthesis
CHECK: Alignment should match open parenthesis
CHECK: Alignment should match open parenthesis
CHECK: Alignment should match open parenthesis
CHECK: Alignment should match open parenthesis
CHECK: Alignment should match open parenthesis
CHECK: Please don't use multiple blank lines
CHECK: DEFINE_MUTEX definition without comment
CHECK: Please use a blank line after function/struct/union/enum declarations
CHECK: Please use a blank line after function/struct/union/enum declarations
CHECK: Please use a blank line after function/struct/union/enum declarations
CHECK: Please use a blank line after function/struct/union/enum declarations
CHECK: Alignment should match open parenthesis
CHECK: Please use a blank line after function/struct/union/enum declarations
