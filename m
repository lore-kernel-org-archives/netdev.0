From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 v3] tc: Show classes in tree view
Date: Wed, 24 Dec 2014 23:09:35 +0200
Message-ID: <20141224210935.GA24242@angus-think.lan>
References: <1419381976-23986-1-git-send-email-vadim4j@gmail.com>
 <20141224121416.77a7a713@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:54365 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504AbaLXVTn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2014 16:19:43 -0500
Received: by mail-la0-f42.google.com with SMTP id gd6so7500415lab.15
        for <netdev@vger.kernel.org>; Wed, 24 Dec 2014 13:19:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20141224121416.77a7a713@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 24, 2014 at 12:14:16PM -0800, Stephen Hemminger wrote:
> On Wed, 24 Dec 2014 02:46:16 +0200
> Vadim Kochan <vadim4j@gmail.com> wrote:
> 
> > From: Vadim Kochan <vadim4j@gmail.com>
> > 
> > Added new '-t[ree]' which shows classes dependency
> > in the tree view. Meanwhile only generic stats info
> > is supported.
> > 
> > e.g.:
> > 
> > $ tc/tc -t class show dev tap0
> > +---(1:2) htb rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
> > |    +---(1:40) htb prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
> > |    +---(1:50) htb rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
> > |    |    +---(1:51) htb prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
> > |    |
> > |    +---(1:60) htb prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
> > |
> > +---(1:1) htb rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
> >      +---(1:10) htb prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
> >      +---(1:20) htb prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
> >      +---(1:30) htb prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
> > 
> > $ tc/tc -t -s class show dev tap0
> > +---(1:2) htb rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
> > |    |    Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> > |    |    rate 0bit 0pps backlog 0b 0p requeues 0
> > |    |
> > |    +---(1:40) htb prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
> > |    |          Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> > |    |          rate 0bit 0pps backlog 0b 0p requeues 0
> > |    |
> > |    +---(1:50) htb rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
> > |    |    |     Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> > |    |    |     rate 0bit 0pps backlog 0b 0p requeues 0
> > |    |    |
> > |    |    +---(1:51) htb prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
> > |    |               Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> > |    |               rate 0bit 0pps backlog 0b 0p requeues 0
> > |    |
> > |    +---(1:60) htb prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
> > |               Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> > |               rate 0bit 0pps backlog 0b 0p requeues 0
> > |
> > +---(1:1) htb rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
> >      |    Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >      |    rate 0bit 0pps backlog 0b 0p requeues 0
> >      |
> >      +---(1:10) htb prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
> >      |          Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >      |          rate 0bit 0pps backlog 0b 0p requeues 0
> >      |
> >      +---(1:20) htb prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
> >      |          Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >      |          rate 0bit 0pps backlog 0b 0p requeues 0
> >      |
> >      +---(1:30) htb prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
> >                 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
> >                 rate 0bit 0pps backlog 0b 0p requeues 0
> > 
> > Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> > ---
> > Changes v3:
> >     Fixed wrong brackets style
> > 
> > Changes v2:
> >     Removed "Date:" from commit message which was added by mistake.
> > 
> > Changes RFC -> PATCH:
> >     #1 get rid of INIT_HLIST_NODE
> >     #2 added sample output to commit message
> >     #3 use "show_tree=1" instead of "show_tree++"
> >     #4 no need update include/hlist.h (because of #1)
> >     #5 changed a little tree output: parentheses around class id instead of qdisc name
> > 
> >  tc/tc.c        |   5 +-
> >  tc/tc_class.c  | 161 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
> >  tc/tc_common.h |   2 +
> >  3 files changed, 165 insertions(+), 3 deletions(-)
> 
> I don't get strict about checkpatch. But ran this patch through and there are some minor
> things that would be good to fix.
>   1. Split long lines like:
> WARNING: line over 80 characters
> #198: FILE: tc/tc_class.c:219:
> +static void tree_cls_show(FILE *fp, char *buf, struct hlist_head *root_list, int level)
> 
>   2. Don't use variable name 'childs', makes sense to call it children instead??
> 
>   3. Don't use space before * as in:
> ERROR: "foo * bar" should be "foo *bar"
> #285: FILE: tc/tc_class.c:305:
> +	struct rtattr * tb[TCA_MAX+1] = {};
> 
> 
> 
> 

I will fix them.
