From: Colin Ian King <colin.king@canonical.com>
Subject: rhashtable concurrent writers issue, 4.2+
Date: Fri, 11 Dec 2015 16:09:04 +0000
Message-ID: <566AF520.4000904@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:45836 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbbLKQJH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 11:09:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

After testing with commit 7def0f952eccdd0edb3c504f4dab35ee0d3aba1f
("lib: fix data race in rhashtable_rehash_one") on the current 4.4-rc4
kernel, I believe I am still seeing race conditions that seem to bite
concurrent readers.

The reproducer is found in my stress-ng system stress tool:

git://kernel.ubuntu.com/cking/stress-ng.git

one needs libattr1-dev, libkeyutils-dev to build this.

run the concurrent procfs stressor on 2 CPUs:

./stress-ng --procfs 2

..sometimes this hangs w/o a kernel stack dump, but sometimes it oopses
and one can see that we get a concurrent reader failure.

Colin
