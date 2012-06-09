From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: iwlwifi: kernel panic during boot due to module load order
Date: Sat, 09 Jun 2012 10:29:04 +0200
Message-ID: <1339230544.4539.21.camel@jlt3.sipsolutions.net>
References: <1339072491.3279.6.camel@lappy>
	 (sfid-20120607_143403_120928_12961A9D)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: donald.h.fry-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1339072491.3279.6.camel@lappy> (sfid-20120607_143403_120928_12961A9D)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-06-07 at 14:34 +0200, Sasha Levin wrote:
> Hi all,
> 
> Commit cc5f7e397 ("iwlwifi: implement dynamic opmode loading") causes a
> kernel panic during boot in the following scenario:
> 
> 1. All drivers are built-in.
> 2. Due to their build order, iwl_init gets called before iwl_drv_init.
> 3. iwl_init will call iwl_opmode_register which will iterate the new op
> list, and cause a NULL ptr deref when trying to list_for_each_entry the
> dev list, which won't be empty since it wasn't initialized (iwl_drv_init
> wasn't called yet).
> 
> While it's possible to easily fix the actual deref, I suspect that the
> init function call order is wrong. I've looked at getting it right in
> the Makefile, but it seems to have specific ordering behind it, so I'd
> rather not try patching it myself.

Yeah, looks like we forgot about this part.

I think Don said he had a fix, my suggestion would be to try to just
reorder the dvm line in the iwlwifi/Makefile to the bottom of the
Makefile, or at least after obj-$(...) += iwlwifi.o.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
