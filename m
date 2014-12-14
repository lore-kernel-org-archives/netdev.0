From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net] net: Disallow providing non zero VLAN ID for NIC
 drivers FDB add flow
Date: Sun, 14 Dec 2014 22:14:27 +0200
Message-ID: <CAJ3xEMhbic5w4d0dGsTMRDoq5Vx8wqZRFpy-q+8HaeDfYciUqw@mail.gmail.com>
References: <1418573945-27840-1-git-send-email-ogerlitz@mellanox.com>
	<20141214192351.GA1850@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:63619 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751022AbaLNUO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2014 15:14:28 -0500
Received: by mail-ob0-f180.google.com with SMTP id wp4so14942186obc.11
        for <netdev@vger.kernel.org>; Sun, 14 Dec 2014 12:14:27 -0800 (PST)
In-Reply-To: <20141214192351.GA1850@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 14, 2014 at 9:23 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Sun, Dec 14, 2014 at 05:19:05PM CET, ogerlitz@mellanox.com wrote:
>>The current implementations all use dev_uc_add_excl() and such whose API
>>doesn't support vlans, so we can't make it with NICs HW for now.
>>
>>Fixes: f6f6424ba773 ('net: make vid as a parameter for ndo_fdb_add/ndo_fdb_del')
>
> Maybe I'm missing something, but this commit did not introduce the
> problem.

This commit introduced the vid param to ndo_fdb_add and ndo_dflt_fdb_add
which further call the dev_uc_add APIs... so it did introduced the
ability to provide VID into these APIs, right? and we want to protect
against anyone using this ability @ this point.

> If was there already before when NDA_VLAN was set and ignored.
> But other than this. I like the patch
>
> Reviewed-by: Jiri Pirko <jiri@resnulli.us>
