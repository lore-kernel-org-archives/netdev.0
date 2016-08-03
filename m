From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: Re: Kernel NFS boot failure
Date: Wed, 3 Aug 2016 18:04:40 +0300
Message-ID: <c234fc25-ef5b-eecc-450f-34d01410f9de@ti.com>
References: <674e6841-d2c5-ccae-6633-a699e848e6d2@ti.com>
 <57A1DE28.7020604@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
 Sekhar Nori <nsekhar@ti.com>, open list <linux-kernel@vger.kernel.org>,
 linux-arm <linux-arm-kernel@lists.infradead.org>
To: Vladimir Murzin <vladimir.murzin@arm.com>, netdev <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <57A1DE28.7020604@arm.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Vladimir,

On 08/03/2016 03:06 PM, Vladimir Murzin wrote:
> On 03/08/16 12:41, Grygorii Strashko wrote:
>> We observe Kernel boot failure while running NFS boot stress test (1000 iterations):
>> - Linux version 4.7.0 

I'd like to pay your attention that this issue also reproducible with
Kernel 4.7.0!
The same can be seen from the log I've provided in first e-mail:
[    0.000000] Linux version 4.7.0 (lcpdbld@dflsdit-build06.dal.design.ti.com) (gcc version 4.9.3 20150413 (prerelease) (Linaro GCC 4.9-2015.05) ) #1 SMP Fri Jul 29 17:41:27 CDT 2016


I've not run the test with current master at it's not been tagged yet.

>> - am335x-evm (TI AM335x EVM)
>> - failure rate 10-20 times per test.
>> Originally this issue was reproduced using TI Kernel 4.4
>> ( git://git.ti.com/ti-linux-kernel/ti-linux-kernel.git, branch: ti-linux-4.4.y)
>> on both am335x-evm and am57xx-beagle-x15(am57xx-evm) platforms.
>> This issues has not been reproduced with TI Kernel 4.1 before.
>>
>> The SysRq shows that system stuck in nfs_fs_mount()
>>
>> [  207.904632] [<c07ab34c>] (schedule) from [<c0783554>] (rpc_wait_bit_killable+0x2c/0xd8)
>> [  207.912996] [<c0783554>] (rpc_wait_bit_killable) from [<c07ab7f0>] (__wait_on_bit+0x84/0xc0)
>> [  207.921812] [<c07ab7f0>] (__wait_on_bit) from [<c07ab890>] (out_of_line_wait_on_bit+0x64/0x70)
>> [  207.930810] [<c07ab890>] (out_of_line_wait_on_bit) from [<c07843f4>] (__rpc_execute+0x18c/0x544)
>> [  207.939988] [<c07843f4>] (__rpc_execute) from [<c0779f24>] (rpc_run_task+0x13c/0x158)
>> [  207.948166] [<c0779f24>] (rpc_run_task) from [<c0779f84>] (rpc_call_sync+0x44/0xc4)
>> [  207.956163] [<c0779f84>] (rpc_call_sync) from [<c077a04c>] (rpc_ping+0x48/0x68)
>> [  207.963796] [<c077a04c>] (rpc_ping) from [<c077a158>] (rpc_create_xprt+0xec/0x164)
>> [  207.971702] [<c077a158>] (rpc_create_xprt) from [<c077a2c0>] (rpc_create+0xf0/0x1a0)
>> [  207.979794] [<c077a2c0>] (rpc_create) from [<c0393088>] (nfs_create_rpc_client+0xd4/0xec)
>> [  207.988338] [<c0393088>] (nfs_create_rpc_client) from [<c0394d10>] (nfs_init_client+0x20/0x78)
>> [  207.997332] [<c0394d10>] (nfs_init_client) from [<c03949d4>] (nfs_create_server+0xa0/0x3bc)
>> [  208.006057] [<c03949d4>] (nfs_create_server) from [<c03b197c>] (nfs3_create_server+0x8/0x20)
>> [  208.014879] [<c03b197c>] (nfs3_create_server) from [<c03a34c4>] (nfs_try_mount+0xc4/0x1f0)
>> [  208.023513] [<c03a34c4>] (nfs_try_mount) from [<c03a2c48>] (nfs_fs_mount+0x290/0x910)
>> [  208.031702] [<c03a2c48>] (nfs_fs_mount) from [<c0294d24>] (mount_fs+0x44/0x168)
>>
>> Has anyone else seen this issue?
>>
>> I'd be appreciated for any help or advice related to this issue?
> 
> I did not look at details, but because it is 4.4 and __wait_on_bit
> showed up you might want to look at [1]
> 
> [1] https://lkml.org/lkml/2015/11/20/472

Thanks. I'll take a look.

-- 
regards,
-grygorii
