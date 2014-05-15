From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH v2 net-next 5/9] bonding: create a macro for bond mode and use it
Date: Thu, 15 May 2014 11:32:41 -0700
Message-ID: <10534.1400178761@localhost.localdomain>
References: <1400156967-8231-1-git-send-email-vfalico@gmail.com> <1400156967-8231-6-git-send-email-vfalico@gmail.com> <10028.1400176311@localhost.localdomain> <20140515181436.GA25181@mikrodark.usersys.redhat.com>
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
To: Veaceslav Falico <vfalico@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:40879 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755797AbaEOScp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 14:32:45 -0400
In-reply-to: <20140515181436.GA25181@mikrodark.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Veaceslav Falico <vfalico@gmail.com> wrote:

>On Thu, May 15, 2014 at 10:51:51AM -0700, Jay Vosburgh wrote:
>>Veaceslav Falico <vfalico@gmail.com> wrote:
>>
>>>CC: Jay Vosburgh <j.vosburgh@gmail.com>
>>>CC: Andy Gospodarek <andy@greyhouse.net>
>>>Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
>>>---
>...snip...
>>	Would it be better to use "bond_uses_primary(struct bonding *)"
>>instead of the above?  That would simplify the above calling pattern,
>>and shorten the calls elsewhere.  Maybe I missed one, but it looks like
>>all of the calls to _uses_primary have BOND_MODE(bond) as the argument.
>
>There's at least one call, when checking the params, where it checks the
>int:
>
>bond_main.c:
>4271         if (primary && !bond_mode_uses_primary(bond_mode)) {
>
>so, either we'll use something else here, or leave it with BOND_MODE()...

	The something else isn't so bad, and would look better for most
callers:

static inline bool bond_uses_primary(struct bonding *bond)
{
	return bond_mode_uses_primary(bond->params.mode);
}

	This ends up replacing "USES_PRIMARY(bond->params.mode)" with
"bond_uses_primary(bond)" for most call sites, which actually looks like
an improvement (it's even shorter).

	-J

---
	-Jay Vosburgh, jay.vosburgh@canonical.com
