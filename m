From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: linux-next: build failure after merge of most of the trees
Date: Thu, 28 May 2015 08:26:51 -0700
Message-ID: <1432826811.7456.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150528220607.67a68696@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:36582 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751556AbbE1P0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 11:26:54 -0400
In-Reply-To: <20150528220607.67a68696@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-28 at 22:06 +1000, Stephen Rothwell wrote:
> Hi all,
> 
> After merging the all the trees, today's linux-next build (powerpc
> allyesconfig) failed like this:
> 
> drivers/vhost/scsi.c: In function 'vhost_scsi_open':
> drivers/vhost/scsi.c:1422:3: error: implicit declaration of function 'vzalloc' [-Werror=implicit-function-declaration]
>    vs = vzalloc(sizeof(*vs));
>    ^
> drivers/vhost/scsi.c:1422:6: warning: assignment makes pointer from integer without a cast
>    vs = vzalloc(sizeof(*vs));
>       ^
> drivers/target/target_core_pr.c: In function 'core_scsi3_update_and_write_aptpl':
> drivers/target/target_core_pr.c:1985:2: error: implicit declaration of function 'vzalloc' [-Werror=implicit-function-declaration]
>   buf = vzalloc(len);
>   ^
> drivers/target/target_core_pr.c:1985:6: warning: assignment makes pointer from integer without a cast
>   buf = vzalloc(len);
>       ^
> drivers/target/target_core_pr.c:1991:3: error: implicit declaration of function 'vfree' [-Werror=implicit-function-declaration]
>    vfree(buf);
>    ^
> drivers/target/target_core_transport.c: In function 'transport_alloc_session_tags':
> drivers/target/target_core_transport.c:258:3: error: implicit declaration of function 'vzalloc' [-Werror=implicit-function-declaration]
>    se_sess->sess_cmd_map = vzalloc(tag_num * tag_size);
>    ^
> drivers/target/target_core_transport.c:258:25: warning: assignment makes pointer from integer without a cast
>    se_sess->sess_cmd_map = vzalloc(tag_num * tag_size);
>                          ^
> drivers/target/target_core_transport.c:270:4: error: implicit declaration of function 'vfree' [-Werror=implicit-function-declaration]
>     vfree(se_sess->sess_cmd_map);
>     ^
> drivers/target/target_core_transport.c: In function 'transport_kmap_data_sg':
> drivers/target/target_core_transport.c:2317:2: error: implicit declaration of function 'vmap' [-Werror=implicit-function-declaration]
>   cmd->t_data_vmap = vmap(pages, cmd->t_data_nents,  VM_MAP, PAGE_KERNEL);
>   ^
> drivers/target/target_core_transport.c:2317:53: error: 'VM_MAP' undeclared (first use in this function)
>   cmd->t_data_vmap = vmap(pages, cmd->t_data_nents,  VM_MAP, PAGE_KERNEL);
>                                                      ^
> drivers/target/target_core_transport.c: In function 'transport_kunmap_data_sg':
> drivers/target/target_core_transport.c:2335:2: error: implicit declaration of function 'vunmap' [-Werror=implicit-function-declaration]
>   vunmap(cmd->t_data_vmap);
>   ^
> drivers/target/target_core_file.c: In function 'fd_format_prot':
> drivers/target/target_core_file.c:809:2: error: implicit declaration of function 'vzalloc' [-Werror=implicit-function-declaration]
>   buf = vzalloc(unit_size);
>   ^
> drivers/target/target_core_file.c:809:6: warning: assignment makes pointer from integer without a cast
>   buf = vzalloc(unit_size);
>       ^
> drivers/target/target_core_file.c:822:2: error: implicit declaration of function 'vfree' [-Werror=implicit-function-declaration]
>   vfree(buf);
>   ^
> drivers/target/target_core_user.c: In function 'tcmu_configure_device':
> drivers/target/target_core_user.c:895:2: error: implicit declaration of function 'vzalloc' [-Werror=implicit-function-declaration]
>   udev->mb_addr = vzalloc(TCMU_RING_SIZE);
>   ^
> drivers/target/target_core_user.c:895:16: warning: assignment makes pointer from integer without a cast
>   udev->mb_addr = vzalloc(TCMU_RING_SIZE);
>                 ^
> drivers/target/target_core_user.c:947:2: error: implicit declaration of function 'vfree' [-Werror=implicit-function-declaration]
>   vfree(udev->mb_addr);
>   ^
> drivers/target/iscsi/iscsi_target.c: In function 'iscsi_target_init_module':
> drivers/target/iscsi/iscsi_target.c:557:2: error: implicit declaration of function 'vzalloc' [-Werror=implicit-function-declaration]
>   iscsit_global->ts_bitmap = vzalloc(size);
>   ^
> drivers/target/iscsi/iscsi_target.c:557:27: warning: assignment makes pointer from integer without a cast
>   iscsit_global->ts_bitmap = vzalloc(size);
>                            ^
> drivers/target/iscsi/iscsi_target.c:615:2: error: implicit declaration of function 'vfree' [-Werror=implicit-function-declaration]
>   vfree(iscsit_global->ts_bitmap);
>   ^
> drivers/scsi/qla2xxx/tcm_qla2xxx.c: In function 'tcm_qla2xxx_init_lport':
> drivers/scsi/qla2xxx/tcm_qla2xxx.c:1578:2: error: implicit declaration of function 'vmalloc' [-Werror=implicit-function-declaration]
>   lport->lport_loopid_map = vmalloc(sizeof(struct tcm_qla2xxx_fc_loopid) *
>   ^
> drivers/scsi/qla2xxx/tcm_qla2xxx.c:1578:26: warning: assignment makes pointer from integer without a cast
>   lport->lport_loopid_map = vmalloc(sizeof(struct tcm_qla2xxx_fc_loopid) *
>                           ^
> drivers/scsi/qla2xxx/tcm_qla2xxx.c: In function 'tcm_qla2xxx_make_lport':
> drivers/scsi/qla2xxx/tcm_qla2xxx.c:1643:2: error: implicit declaration of function 'vfree' [-Werror=implicit-function-declaration]
>   vfree(lport->lport_loopid_map);
>   ^
> 
> Ouch :-(
> 
> Maybe commit 095dc8e0c368 ("tcp: fix/cleanup
> inet_ehash_locks_alloc()")?  (that is the only commit I can find that
> remove an include of vmalloc.h
> 
> Ah ha.  I applied this fix patch:
> 
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Thu, 28 May 2015 21:54:40 +1000
> Subject: [PATCH] try putting the include of vmalloc.h back into inet_hashtables.h
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  include/net/inet_hashtables.h | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
> index b73c88a19dd4..0046b9f91ed3 100644
> --- a/include/net/inet_hashtables.h
> +++ b/include/net/inet_hashtables.h
> @@ -24,6 +24,7 @@
>  #include <linux/spinlock.h>
>  #include <linux/types.h>
>  #include <linux/wait.h>
> +#include <linux/vmalloc.h>
>  
>  #include <net/inet_connection_sock.h>
>  #include <net/inet_sock.h>
> -- 

Hi Stephen

We were alerted of this problem thanks to kbuild test robot.

This fix is not a definitive one I hope.

Golden rule is that vmalloc() users must include vmalloc.h themselves,
not by an indirect include.

include/net/inet_hashtables.h no longer uses vmalloc(), so this include
is not needed anymore.

I sent one fix, and prepared others, but I prefer that each offender is
fixed.

http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=c6bfda8d72c485b2eee1642cbcbd92e3fbb93ed3

Thanks
