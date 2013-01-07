From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: bnx2x: Prepare device and initialize VF database
Date: Mon, 7 Jan 2013 11:18:37 +0300
Message-ID: <20130107081836.GA5023@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: ariele@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:31355 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753744Ab3AGISk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 03:18:40 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ariel Elior,

The patch b56e9670ffa4: "bnx2x: Prepare device and initialize VF
database" from Jan 1, 2013, leads to the following warning:
drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c:1346
bnx2x_pretend_func()
	 warn: should this be '>= E1H_FUNC_MAX'

drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c
  1342  int bnx2x_pretend_func(struct bnx2x *bp, u16 pretend_func_val)
  1343  {
  1344          u32 pretend_reg;
  1345  
  1346          if (CHIP_IS_E1H(bp) && pretend_func_val > E1H_FUNC_MAX)
  1347                  return -1;
  1348  

This is static checker test has too many false positives so I haven't
released it.  Basically, every other place that uses E1H_FUNC_MAX
assumes we start counting from zero except this one.  I don't know the
code enough to say if it's a problem or intended.

regards,
dan carpenter
