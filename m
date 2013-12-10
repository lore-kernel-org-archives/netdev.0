From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net v7 0/2] net: sched: fix two issues
Date: Tue, 10 Dec 2013 11:49:16 +0800
Message-ID: <1386647358-47944-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <brouer@redhat.com>, <jpirko@redhat.com>,
	<jbrouer@redhat.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:1702 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048Ab3LJDt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 22:49:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix calculation of max_size in tbf
fix quantum calculation introduced by 64bit rates.

v7
  patch 1/2:
  1.Set member of "struct tbf_sched_data *q" after calculating
  max_size successfully, or it will change the old settings while
  calculating failed.
  2.If time_in_ns is bigger than ~0U(about 4 sec), it's useless,
  use ~0U instead.

v6
  patch 1/2:
  1.Use a simpler and better way to calculate length in psched_ns_t2l().
  2.Replace pr_err() with pr_warn_ratelimited().

  patch 2/2: Replace div64_u64() with do_div() suggested by Eric.

v5
  patch 1/2:
  1.Remove rtab and ptab use suggested by Eric.
  2.Don't reduce max_size to 65536, as Eric suggested that
    if a burst set to 200KB, we do not want tbf use 64KB
    or even less. So add a helper psched_ns_t2l to calculate
    max_size directly.

v4
  patch 1/2:
  1.Update commit message suggested by Jesper.
  2.Use a macro to replace 65535 constant.
  3.Add condition that when peakrate is lower than rate, return -EINVAL.
  4.Don't use cell_log anymore.

v3
  patch 1/2: use psched_l2t_ns to calculate max_size
  and cleanup exit/done section suggested by Jesper.

v2
  patch 1/2: redescribe the regression.
  patch 2/2: add Eric's ack.

*** BLURB HERE ***

Yang Yingliang (2):
  net: sched: tbf: fix the calculation of max_size
  net: sched: htb: fix the calculation of quantum

 net/sched/sch_htb.c |  20 +++++----
 net/sched/sch_tbf.c | 119 +++++++++++++++++++++++++++++++---------------------
 2 files changed, 83 insertions(+), 56 deletions(-)

-- 
1.8.0
