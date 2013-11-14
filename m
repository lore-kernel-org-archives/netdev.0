From: Markos Chandras <Markos.Chandras@imgtec.com>
Subject: Re: linux-next: manual merge of the random tree with the net-next
 tree
Date: Thu, 14 Nov 2013 15:17:55 +0000
Message-ID: <5284E9A3.8010100@imgtec.com>
References: <20131112155549.c160273993147244ed6bc81d@canb.auug.org.au>	<5281ED01.5020204@redhat.com> <20131113074657.287f83d9669c8144865a77b6@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Theodore Ts'o <tytso@mit.edu>, <linux-next@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20131113074657.287f83d9669c8144865a77b6@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/12/2013 08:46 PM, Stephen Rothwell wrote:
> Hi Daniel,
>
> On Tue, 12 Nov 2013 09:55:29 +0100 Daniel Borkmann <dborkman@redhat.com> wrote:
>>
>> On 11/12/2013 05:55 AM, Stephen Rothwell wrote:
>>>
>>> Today's linux-next merge of the random tree got a conflict in
>>> drivers/char/random.c between commit 0244ad004a54 ("random32: add
>>> prandom_reseed_late() and call when nonblocking pool becomes
>>> initialized") from the net-next tree and commit 301f0595c0e7 ("random:
>>> printk notifications for urandom pool initialization") from the random
>>> tree.
>>>
>>> I fixed it up (probably not properly - see below) and can carry the fix
>>> as necessary (no action is required).
>>
>> As per Hannes' suggestion, the result should look like (see cover
>> letter in [1]):
>>
>> if (r->entropy_total > 128) {
>> 	r->initialized = 1;
>> 	r->entropy_total = 0;
>> 	if (r == &nonblocking_pool) {
>> 		prandom_reseed_late();
>> 		pr_notice("random: %s pool is initialized\n",
>> 			  r->name);
>> 	}
>> }
>
> I will use that from today.  Thanks.
>

Hi Stephen,

This broke the build for MIPS for the malta_defconfig when using the 
latest Mentor toolchain.

In file included from include/linux/fs.h:16:0,
                  from fs/fuse/fuse_i.h:13,
                  from fs/fuse/file.c:9:
fs/fuse/file.c: In function 'fuse_file_poll':
include/linux/rbtree.h:82:28: warning: 'parent' may be used 
uninitialized in this function [-Wmaybe-uninitialized]
fs/fuse/file.c:2580:27: note: 'parent' was declared here
drivers/char/random.c: In function 'init_std_data':
drivers/char/random.c:1249:1: internal compiler error: in 
add_insn_before, at emit-rtl.c:3857
Please submit a full bug report,
with preprocessed source if appropriate.
See <https://sourcery.mentor.com/GNUToolchain/> for instructions.
make[2]: *** [drivers/char/random.o] Error 1
make[1]: *** [drivers/char] Error 2
make: *** [drivers] Error 2
make: *** Waiting for unfinished jobs....


If you want to reproduce it you can do the following steps:
- Get a MIPS Mentor toolchain from 
https://sourcery.mentor.com/GNUToolchain/release2554
- make ARCH=mips CROSS_COMPILE=$TOOLCHAIN_PATH/bin/mips-linux-gnu- 
malta_defconfig
- make ARCH=mips CROSS_COMPILE=$TOOLCHAIN_PATH/bin/mips-linux-gnu-


We are working with the toolchain group to come up with a workaround in 
the code to resolve the problem.

-- 
markos
