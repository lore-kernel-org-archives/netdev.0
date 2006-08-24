From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] add nl80211
Date: Thu, 24 Aug 2006 17:20:46 +0200
Message-ID: <1156432846.10283.6.camel@ux156>
References: <1156254768.3825.1.camel@ux156>
	 <20060824143634.GM3470@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:956 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S964986AbWHXPUV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Aug 2006 11:20:21 -0400
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20060824143634.GM3470@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-08-24 at 16:36 +0200, Thomas Graf wrote:

> Might want to put this in a header so userspace can see the limit.

Good point, thanks.

> In your case I'd call it GET_CMDLIST and NEW_CMDLIST which
> means you request a command list with GET_CMDLIST and
> receive the answer with a CMD_NEWLIST message.

Yeah, ok, I think I understood this now :)


> I'd just use the command id as attribute type:
> 
> 	NLA_PUT_FLAG(msg, NL80211_CMD_GET_COMMANDS);
> 	NLA_PUT_FLAG(msg, NL80211_CMD_GET_WIPHYS);
> 	....
> 
> This makes checking avaibility of a command as easy as
> accessing an array for userspace.

Good point. However, userspace will need to be aware to parse this with
the max_cmd instead of max_attr :)

> > +	err = genlmsg_end(msg, hdr);
> > +	if (err)
> > +		goto msg_free;
> 
> genlmsg_end() can't fail, it just returns skb->len which
> is only of importance while dumping to see if there is
> still more to dump or not.

Whoops :)

> You might want to send out notifications for various events such as the
> additiona and deletion of virtual interfaces etc.

Yeah, I'm not sure how to do that yet, maybe have exported functions.
Currently, d80211 can also create virtual interfaces via sysfs so...

johannes
