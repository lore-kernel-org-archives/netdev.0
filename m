From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net] ematch: Fix auto-loading of ematch modules.
Date: Mon, 16 Feb 2015 10:36:06 -0800
Message-ID: <CAHA+R7McGmFtXpiEJkOV2Jjgy29kzpX7tTeprS7S0pY2m9mJBw@mail.gmail.com>
References: <20150216150329.GB16798@zenon.in.qult.net>
	<20150216181315.GA15280@zenon.in.qult.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?UTF-8?Q?Ignacy_Gaw=C4=99dzki?=
	<ignacy.gawedzki@green-communications.fr>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:60018 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753356AbbBPSgH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 13:36:07 -0500
Received: by mail-ig0-f178.google.com with SMTP id hl2so25268365igb.5
        for <netdev@vger.kernel.org>; Mon, 16 Feb 2015 10:36:06 -0800 (PST)
In-Reply-To: <20150216181315.GA15280@zenon.in.qult.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 16, 2015 at 10:13 AM, Ignacy Gaw=C4=99dzki
<ignacy.gawedzki@green-communications.fr> wrote:
> In tcf_em_validate(), when calling tcf_em_lookup(), don't put the res=
ulting
> pointer directly into em->ops, if the function is to possibly return =
-EAGAIN
> after module auto-loading.  Otherwise, module_put() will be called by
> tcf_em_tree_destroy() on em->ops->owner, while it has already been ca=
lled by
> tcf_em_validate() before return.
>

Or simply reset em->ops to NULL after module_put()?
