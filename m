From: Ignacy =?iso-8859-2?Q?Gaw=EAdzki?=
	<ignacy.gawedzki@green-communications.fr>
Subject: Re: [PATCH net] ematch: Fix auto-loading of ematch modules.
Date: Mon, 16 Feb 2015 19:50:11 +0100
Message-ID: <20150216185011.GA29935@zenon.in.qult.net>
References: <20150216150329.GB16798@zenon.in.qult.net>
 <20150216181315.GA15280@zenon.in.qult.net>
 <CAHA+R7McGmFtXpiEJkOV2Jjgy29kzpX7tTeprS7S0pY2m9mJBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [78.193.33.39] ([78.193.33.39]:58555 "EHLO mail.qult.net"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752990AbbBPSum (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Feb 2015 13:50:42 -0500
Content-Disposition: inline
In-Reply-To: <CAHA+R7McGmFtXpiEJkOV2Jjgy29kzpX7tTeprS7S0pY2m9mJBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 16, 2015 at 10:36:06AM -0800, thus spake Cong Wang:
> On Mon, Feb 16, 2015 at 10:13 AM, Ignacy Gaw=EAdzki
> <ignacy.gawedzki@green-communications.fr> wrote:
> > In tcf_em_validate(), when calling tcf_em_lookup(), don't put the r=
esulting
> > pointer directly into em->ops, if the function is to possibly retur=
n -EAGAIN
> > after module auto-loading.  Otherwise, module_put() will be called =
by
> > tcf_em_tree_destroy() on em->ops->owner, while it has already been =
called by
> > tcf_em_validate() before return.
> >
>=20
> Or simply reset em->ops to NULL after module_put()?

Yeah, why not.  I just got my inspiration from what's done in cls_api.c=
 and
act_api.c.  What do you think, should the same simplification be applie=
d to
cls_api.c?

--=20
Ignacy Gaw=EAdzki
R&D Engineer
Green Communications
