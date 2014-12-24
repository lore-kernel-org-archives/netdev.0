From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v3] tc: Show classes in tree view
Date: Wed, 24 Dec 2014 12:14:16 -0800
Message-ID: <20141224121416.77a7a713@urahara>
References: <1419381976-23986-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:57055 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448AbaLXUO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 15:14:26 -0500
Received: by mail-pd0-f179.google.com with SMTP id fp1so10348315pdb.24
        for <netdev@vger.kernel.org>; Wed, 24 Dec 2014 12:14:25 -0800 (PST)
In-Reply-To: <1419381976-23986-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Dec 2014 02:46:16 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> From: Vadim Kochan <vadim4j@gmail.com>
> 
> Added new '-t[ree]' which shows classes dependency
> in the tree view. Meanwhile only generic stats info
> is supported.
> 
> e.g.:
> 
> $ tc/tc -t class show dev tap0
> +---(1:2) htb rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
> |    +---(1:40) htb prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
> |    +---(1:50) htb rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
> |    |    +---(1:51) htb prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
> |    |
> |    +---(1:60) htb prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
> |
> +---(1:1) htb rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
>      +---(1:10) htb prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
>      +---(1:20) htb prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
>      +---(1:30) htb prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
> 
> $ tc/tc -t -s class show dev tap0
> +---(1:2) htb rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
> |    |    Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> |    |    rate 0bit 0pps backlog 0b 0p requeues 0
> |    |
> |    +---(1:40) htb prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
> |    |          Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> |    |          rate 0bit 0pps backlog 0b 0p requeues 0
> |    |
> |    +---(1:50) htb rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
> |    |    |     Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> |    |    |     rate 0bit 0pps backlog 0b 0p requeues 0
> |    |    |
> |    |    +---(1:51) htb prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
> |    |               Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> |    |               rate 0bit 0pps backlog 0b 0p requeues 0
> |    |
> |    +---(1:60) htb prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
> |               Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> |               rate 0bit 0pps backlog 0b 0p requeues 0
> |
> +---(1:1) htb rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
>      |    Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>      |    rate 0bit 0pps backlog 0b 0p requeues 0
>      |
>      +---(1:10) htb prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
>      |          Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>      |          rate 0bit 0pps backlog 0b 0p requeues 0
>      |
>      +---(1:20) htb prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
>      |          Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>      |          rate 0bit 0pps backlog 0b 0p requeues 0
>      |
>      +---(1:30) htb prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
>                 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>                 rate 0bit 0pps backlog 0b 0p requeues 0
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
> Changes v3:
>     Fixed wrong brackets style
> 
> Changes v2:
>     Removed "Date:" from commit message which was added by mistake.
> 
> Changes RFC -> PATCH:
>     #1 get rid of INIT_HLIST_NODE
>     #2 added sample output to commit message
>     #3 use "show_tree=1" instead of "show_tree++"
>     #4 no need update include/hlist.h (because of #1)
>     #5 changed a little tree output: parentheses around class id instead of qdisc name
> 
>  tc/tc.c        |   5 +-
>  tc/tc_class.c  | 161 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  tc/tc_common.h |   2 +
>  3 files changed, 165 insertions(+), 3 deletions(-)

I don't get strict about checkpatch. But ran this patch through and there are some minor
things that would be good to fix.
  1. Split long lines like:
WARNING: line over 80 characters
#198: FILE: tc/tc_class.c:219:
+static void tree_cls_show(FILE *fp, char *buf, struct hlist_head *root_list, int level)

  2. Don't use variable name 'childs', makes sense to call it children instead??

  3. Don't use space before * as in:
ERROR: "foo * bar" should be "foo *bar"
#285: FILE: tc/tc_class.c:305:
+	struct rtattr * tb[TCA_MAX+1] = {};
