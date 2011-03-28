From: Dan Carpenter <error27@gmail.com>
Subject: smatch stuff: use after free bug
Date: Mon, 28 Mar 2011 13:31:40 +0300
Message-ID: <20110328103140.GJ1885@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:53977 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205Ab1C1Kb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 06:31:58 -0400
Received: by fxm17 with SMTP id 17so2509312fxm.19
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2011 03:31:57 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch complains about this.  It's not obvious to me how to fix it.  The
bug was introduced in b12d93d63 "mlx4: Add support for promiscuous mode
in the new steering model.".

drivers/net/mlx4/mcg.c +530
	remove_promisc_qp(89) warn: 'pqp' was already freed.

   526  out_mailbox:
   527          mlx4_free_cmd_mailbox(dev, mailbox);
   528  out_list:
   529          if (back_to_list)
   530                  list_add_tail(&pqp->list, &s_steer->promisc_qps[steer]);
                                      ^^^^^^^^^^

This list was deleted and pqp was freed at this point.

   531  out_mutex:
   532          mutex_unlock(&priv->mcg_table.mutex);
   533          return err;
   534  }

regards,
dan carpenter
