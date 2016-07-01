From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net 00/13] Mellanox 100G mlx5 resiliency and xmit path fixes
Date: Fri, 1 Jul 2016 14:11:28 +0300
Message-ID: <CALzJLG_Z-bvZYR=LNHg859bAuEFYpTCg5GrtOSUSEgaQQDKzbw@mail.gmail.com>
References: <1467297290-11443-1-git-send-email-saeedm@mellanox.com> <20160701.061449.151195686797738506.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35828 "EHLO
	mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963AbcGALLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 07:11:48 -0400
Received: by mail-qk0-f195.google.com with SMTP id b136so22732296qkg.2
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 04:11:48 -0700 (PDT)
In-Reply-To: <20160701.061449.151195686797738506.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 1, 2016 at 1:14 PM, David Miller <davem@davemloft.net> wrote:
> From: Saeed Mahameed <saeedm@mellanox.com>
> Date: Thu, 30 Jun 2016 17:34:37 +0300
>
>> This series provides two set of fixes to the mlx5 driver:
>>       - Resiliency fixes for reset flow and internal pci errors
>>       - xmit path fixes
>
> Series applied to 'net' but expecting all of this to be backported
> to -stable is unreasonable.
>

Thanks Dave,

One small comment on this series is that it will hit two trivial
conflicts once net is merged into current net-next.

Conflict applying: "net/mlx5e: Timeout if SQ doesn't flush during close":
Fix:
 ---
@@@ -810,12 -802,19 +820,19 @@@ static void mlx5e_close_sq(struct mlx5e
                if (mlx5e_sq_has_room_for(sq, 1))
                        mlx5e_send_nop(sq, true);

-               mlx5e_modify_sq(sq, MLX5_SQC_STATE_RDY, MLX5_SQC_STATE_ERR,
-                               false, 0);
 -              err = mlx5e_modify_sq(sq, MLX5_SQC_STATE_RDY,
 -                                    MLX5_SQC_STATE_ERR);

++              err = mlx5e_modify_sq(sq, MLX5_SQC_STATE_RDY,
MLX5_SQC_STATE_ERR,
++                                    false, 0);
+               if (err)
+                       set_bit(MLX5E_SQ_STATE_TX_TIMEOUT, &sq->state);

---

Conflict applying: "net/mlx5e: Handle RQ flush in error cases"
Fix:

---
diff --cc drivers/net/ethernet/mellanox/mlx5/core/en.h
index 6db979e,b429591..0000000
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h

@@@ -214,7 -191,7 +214,8 @@@ struct mlx5e_tstamp
  enum {
                MLX5E_RQ_STATE_POST_WQES_ENABLE,
                MLX5E_RQ_STATE_UMR_WQE_IN_PROGRESS,
 +            MLX5E_RQ_STATE_AM,
+             MLX5E_RQ_STATE_FLUSH_TIMEOUT,
  };

---

Thanks,
Saeed
