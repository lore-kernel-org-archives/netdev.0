From: David Decotigny <decot@google.com>
Subject: Re: [PATCH 1/2] forcedeth: make module parameters readable in /sys/module
Date: Wed, 18 May 2011 16:21:10 -0700
Message-ID: <BANLkTim1iVEU_+Y2CE90Qd3+LaVch2MVOg@mail.gmail.com>
References: <1305753000-14933-1-git-send-email-decot@google.com> <20110518150346.508d6406@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-net-upstream@google.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:20726 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755659Ab1ERXVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 19:21:32 -0400
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p4INLVGQ015128
	for <netdev@vger.kernel.org>; Wed, 18 May 2011 16:21:31 -0700
Received: from qwi2 (qwi2.prod.google.com [10.241.195.2])
	by wpaz29.hot.corp.google.com with ESMTP id p4INKqb1008500
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 18 May 2011 16:21:30 -0700
Received: by qwi2 with SMTP id 2so1474062qwi.8
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 16:21:30 -0700 (PDT)
In-Reply-To: <20110518150346.508d6406@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

On Wed, May 18, 2011 at 3:03 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> Although this makes more info for developer, it also means more
> stuff in sysfs taking more memory and not providing any real value

Right. I'll drop this patch for now.

I do agree that this creates unnecessary pressure on some systems. But
on other systems, it is useful to know how all the loaded modules were
actually configured to track down something weird.

Regarding /sys/modules/X/parameters, the only knobs I know of are
CONFIG_SYSFS and the last argument to module_param(). If this is
correct, then it seems tricky to accommodate for both use cases above
without being crude (eg. disable sysfs, edit/sed the sources to change
last argument of module_param() macro, ...). Please correct me if I am
wrong. But if I am not, how about having a new knob allowing to
precisely control the presence/absence of /sys/module (another
CONFIG_*)? That way, the last argument to module_param() can be
interpreted as the permission when /sys/module is supported, and would
be ignored otherwise: module authors could gradually change their
perm=S_IRUGO and family without caring much about memory footprint.
And both use cases above could be supported without having to disable
sysfs altogether or change the sources.

I would be happy to work on this if it makes any sense.

Regards,
