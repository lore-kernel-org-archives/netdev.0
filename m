From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 1/2] NFC: delete null dereference
Date: Mon, 19 Oct 2015 15:57:50 +0300
Message-ID: <20151019125750.GG7340@mwanda>
References: <1445074340-21955-1-git-send-email-Julia.Lawall@lip6.fr>
 <1445074340-21955-2-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	kernel-janitors@vger.kernel.org,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:29449 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752446AbbJSM6c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 08:58:32 -0400
Content-Disposition: inline
In-Reply-To: <1445074340-21955-2-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The next goto after that is messed up as well:

  1056          dev = nfc_get_device(idx);
  1057          if (!dev)
  1058                  return -ENODEV;
  1059  
  1060          device_lock(&dev->dev);
  1061  
  1062          local = nfc_llcp_find_local(dev);
  1063          if (!local) {
  1064                  nfc_put_device(dev);

It should not call nfc_put_device() because that happens after goto
exit.

  1065                  rc = -ENODEV;
  1066                  goto exit;
  1067          }

regards,
dan carpenter
