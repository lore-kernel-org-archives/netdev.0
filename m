From: Constantine Shulyupin <const@makelinux.com>
Subject: mvneta.c, MVNETA_TXQ_UPDATE_REG, shut down issue
Date: Sat, 18 Jul 2015 21:48:59 +0300
Message-ID: <CAE7jHC8DxVckjEUTfO5CDA+EwBmQ5=0udVyEUqczp5_zT90Q8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: rosenr@marvell.com,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:34960 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752237AbbGRStA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jul 2015 14:49:00 -0400
Received: by wibxm9 with SMTP id xm9so61737015wib.0
        for <netdev@vger.kernel.org>; Sat, 18 Jul 2015 11:48:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rami and Thomas,

I try to run vanilla kernel 4.2.0 on custom Armada-370 board, based on
DB-88F6710-BP.

The problem is that the board shuts down after writing to
MVNETA_TXQ_UPDATE_REG in this code:

static void mvneta_txq_pend_desc_add(struct mvneta_port *pp,
                                     struct mvneta_tx_queue *txq,
                                     int pend_desc)
{
        u32 val;

        /* Only 255 descriptors can be added at once ; Assume caller
         * process TX desriptors in quanta less than 256
         */
        val = pend_desc;
        mvreg_write(pp, MVNETA_TXQ_UPDATE_REG(txq->id), val);
}

BTW, pend_desc == 1

What can you suggest?

Thanks
Constantine
