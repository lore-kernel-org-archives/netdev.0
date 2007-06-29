From: jamal <hadi@cyberus.ca>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Fri, 29 Jun 2007 09:11:45 -0400
Message-ID: <1183122705.5188.35.camel@localhost>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <1179831825.4121.30.camel@localhost>
	 <1180258853.7707.53.camel@localhost.localdomain>
	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>
	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
	 <1181811576.5411.27.camel@localhost.localdomain>
	 <1181820510.4091.9.camel@localhost>
	 <1181869285.5411.39.camel@localhost.localdomain>
	 <1182178882.4063.11.camel@localhost>
	 <1182223964.5411.76.camel@localhost.localdomain>
	 <1182811210.6644.22.camel@johannes.berg>
	 <1182986681.5155.55.camel@localhost>
	 <1183121869.4089.57.camel@johannes.berg>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Zhang Rui <rui.zhang@intel.com>, netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>, Patrick McHardy <kaber@trash.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.232]:2219 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750830AbXF2NLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 09:11:51 -0400
Received: by wx-out-0506.google.com with SMTP id h31so831994wxd
        for <netdev@vger.kernel.org>; Fri, 29 Jun 2007 06:11:50 -0700 (PDT)
In-Reply-To: <1183121869.4089.57.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-29-06 at 14:57 +0200, Johannes Berg wrote:
> On Wed, 2007-06-27 at 19:24 -0400, jamal wrote:

> Hm. I'm starting to dislike the dynamic registration the more I think
> about it. Now when a group is unregistered I'd have to unbind everybody
> who's currently using it... 

I understood you earlier to say only one family (in kernel) can own a
group else it is an error, no? So there is "somebody" but not
"everybody"
BTW, refer to my earlier email in response to Patrick. I think
preserving a group per family is also an interesting idea. i.e
the first 2^16 are reserved/static and the others are in all for
grabs area.

> At least when I want to enforce
> root/non-root binds which is a further goal.

Permissions would be group attributes - maybe something in the group
struct to say who is allowed to bind?

> > c) Use a global hash table to store all the genl_multicast_groups;
> > I think this (handwaving) should be searchable by i) name ii)ID and iii)
> > family. 
> 
> Also, it doesn't look like I'll ever be searching for a group unless we
> want to allow userspace to explicitly ask for a group ID, but I'd think
> it should just get the list of all IDs when asking for family
> information and then cache that.

I think its useful to have the filters in the kernel when
possible/sensible (one of my beefs against netlink in general is it
lacks that).

cheers,
jamal


> johannes

