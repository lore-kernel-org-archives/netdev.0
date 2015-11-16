From: Stephen Hemminger <stephen@networkplumber.org>
Subject: mlx5 Coverity reported issues
Date: Mon, 16 Nov 2015 09:46:28 -0800
Message-ID: <20151116094628.04d7ab3f@samsung9>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eli Cohen <eli@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33294 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbbKPRqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 12:46:31 -0500
Received: by pabfh17 with SMTP id fh17so184381130pab.0
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 09:46:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

** CID 1056375:  Error handling issues  (CHECKED_RETURN)
/drivers/net/ethernet/mellanox/mlx5/core/cq.c: 133 in mlx5_core_create_cq()


________________________________________________________________________________________________________
*** CID 1056375:  Error handling issues  (CHECKED_RETURN)
/drivers/net/ethernet/mellanox/mlx5/core/cq.c: 133 in mlx5_core_create_cq()
127     	return 0;
128     
129     err_cmd:
130     	memset(&din, 0, sizeof(din));
131     	memset(&dout, 0, sizeof(dout));
132     	din.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_DESTROY_CQ);
>>>     CID 1056375:  Error handling issues  (CHECKED_RETURN)
>>>     Calling "mlx5_cmd_exec" without checking return value (as is done elsewhere 44 out of 46 times).
133     	mlx5_cmd_exec(dev, &din, sizeof(din), &dout, sizeof(dout));
134     	return err;
135     }
136     EXPORT_SYMBOL(mlx5_core_create_cq);
137     
138     int mlx5_core_destroy_cq(struct mlx5_core_dev *dev, struct mlx5_core_cq *cq)

** CID 1056376:  Error handling issues  (CHECKED_RETURN)
/drivers/net/ethernet/mellanox/mlx5/core/qp.c: 242 in mlx5_core_create_qp()


________________________________________________________________________________________________________
*** CID 1056376:  Error handling issues  (CHECKED_RETURN)
/drivers/net/ethernet/mellanox/mlx5/core/qp.c: 242 in mlx5_core_create_qp()
236     
237     err_cmd:
238     	memset(&din, 0, sizeof(din));
239     	memset(&dout, 0, sizeof(dout));
240     	din.hdr.opcode = cpu_to_be16(MLX5_CMD_OP_DESTROY_QP);
241     	din.qpn = cpu_to_be32(qp->qpn);
>>>     CID 1056376:  Error handling issues  (CHECKED_RETURN)
>>>     Calling "mlx5_cmd_exec" without checking return value (as is done elsewhere 44 out of 46 times).
242     	mlx5_cmd_exec(dev, &din, sizeof(din), &out, sizeof(dout));
243     
244     	return err;
245     }
246     EXPORT_SYMBOL_GPL(mlx5_core_create_qp);
247     
