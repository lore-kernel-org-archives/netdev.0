From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Subject: fib6_del_route has redundant code
Date: Thu, 27 Dec 2007 15:26:46 +0800
Message-ID: <477353B6.6000102@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52093 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751258AbXL0H1l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Dec 2007 02:27:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
I think the following code in fib6_del_route in the latest kernel is useless.
1125         if (fn->leaf == NULL && fn->fn_flags&RTN_TL_ROOT)
1126                 fn->leaf = &ip6_null_entry;

ip6_null_entry will never be unlinked from fn->leaf now, that is, fn->leaf == NULL will never meet.

In previous kernel, When adding a default route, ip6_null_entry will be unlinked from fn->leaf.
So, when deleting a default route, it need to check whether the deleted route is the last one,
if so, ip6_null_entry will link to fn->leaf again.

I am not sure if there is another place unlinks ip6_null_entry from fn->leaf.

Regards,
Gui Jiafeng
