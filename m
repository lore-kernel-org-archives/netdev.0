From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [patch -next] qed: potential overflow in qed_cxt_src_t2_alloc()
Date: Tue, 7 Jun 2016 12:16:01 +0000
Message-ID: <CO2PR11MB00884D3E0A999631A0E6E447975D0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <20160607120416.GA2175@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ariel Elior <Ariel.Elior@qlogic.com>,
	Dept-Eng Everest Linux L2 <everest-linux-l2@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0107.outbound.protection.outlook.com ([157.56.111.107]:52448
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751290AbcFGMQG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 08:16:06 -0400
In-Reply-To: <20160607120416.GA2175@mwanda>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> In the current code "ent_per_page" could be more than "conn_num" making
> "conn_num" negative after the subtraction.  In the next iteration through the
> loop then the negative is treated as a very high positive meaning we don't put a
> limit on "ent_num".  It could lead to memory corruption.
> 
> Fixes: dbb799c39717 ('qed: Initialize hardware for new protocols')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

I don't think we can actually hit an issue here, since the number of iterations
was also calculated based on conn_num, so this can only happen on the last
iteration.

Regardless, yours is the correct way to go. Thanks, Yuval.

Acked-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
