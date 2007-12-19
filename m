From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: TSO trimming question
Date: Wed, 19 Dec 2007 23:46:33 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712192336130.27945@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48817 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbXLSVqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 16:46:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I'm not fully sure what's purpose of this code in tcp_write_xmit:

                       if (skb->len < limit) {
                               unsigned int trim = skb->len % mss_now;

                               if (trim)
                                       limit = skb->len - trim;
			}

Is it used to make sure we send only multiples of mss_now here and leave 
the left-over into another skb? Or does it try to make sure that
tso_fragment result honors multiple of mss_now boundaries when snd_wnd
is the limitting factor? For latter IMHO this would be necessary:

			if (skb->len > limit)
				limit -= limit % mss_now;


-- 
 i.
