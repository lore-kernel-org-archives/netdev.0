From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: More wireless problems..
Date: Sun, 17 Aug 2014 23:37:11 -0500
Message-ID: <CA+55aFwUJLZUi4wDKwiX1XAht=H9exmvUD5P_aNHK9=XBSixjA@mail.gmail.com>
References: <CA+55aFwTGDFgRuPS5DaQ9-XMLgbZ0y6ZtvXLsZhFkM6P_kXQHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Michal Kazior <michal.kazior@tieto.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f169.google.com ([209.85.220.169]:51845 "EHLO
	mail-vc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762AbaHREhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2014 00:37:12 -0400
In-Reply-To: <CA+55aFwTGDFgRuPS5DaQ9-XMLgbZ0y6ZtvXLsZhFkM6P_kXQHw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 17, 2014 at 11:01 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
>   BUG: unable to handle kernel NULL pointer dereference at 0000000000000020
>   IP: ieee80211_vif_use_reserved_switch+0x71c/0xb00 [mac80211]

Looking at the Code: line and the code generation for that function,
this *looks* to be this code:

                        list_del(&sdata->reserved_chanctx_list);
                        list_move(&sdata->assigned_chanctx_list,
                                  &new_ctx->assigned_vifs);
                        sdata->reserved_chanctx = NULL;

in ieee80211_vif_use_reserved_switch(), where "new_ctx" is NULL, so
the "list_move()" ends up oopsing. But maybe I screwed up the
analysis, I don't know the code.

Looks like that is all-new code introduced by commit 5bcae31d9cb1
("mac80211: implement multi-vif in-place reservations")

And doesn't look at all IWL-specific. Adding Michal Kazior to the list
of people.

                Linus
