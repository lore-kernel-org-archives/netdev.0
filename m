From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] net: Disallow providing non zero VLAN ID for NIC
 drivers FDB add flow
Date: Sun, 14 Dec 2014 23:33:54 +0100
Message-ID: <20141214223354.GA2035@nanopsycho.orion>
References: <1418573945-27840-1-git-send-email-ogerlitz@mellanox.com>
 <20141214192351.GA1850@nanopsycho.orion>
 <CAJ3xEMhbic5w4d0dGsTMRDoq5Vx8wqZRFpy-q+8HaeDfYciUqw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:46645 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbaLNWd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Dec 2014 17:33:57 -0500
Received: by mail-wi0-f175.google.com with SMTP id l15so7214749wiw.8
        for <netdev@vger.kernel.org>; Sun, 14 Dec 2014 14:33:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMhbic5w4d0dGsTMRDoq5Vx8wqZRFpy-q+8HaeDfYciUqw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sun, Dec 14, 2014 at 09:14:27PM CET, gerlitz.or@gmail.com wrote:
>On Sun, Dec 14, 2014 at 9:23 PM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Sun, Dec 14, 2014 at 05:19:05PM CET, ogerlitz@mellanox.com wrote:
>>>The current implementations all use dev_uc_add_excl() and such whose API
>>>doesn't support vlans, so we can't make it with NICs HW for now.
>>>
>>>Fixes: f6f6424ba773 ('net: make vid as a parameter for ndo_fdb_add/ndo_fdb_del')
>>
>> Maybe I'm missing something, but this commit did not introduce the
>> problem.
>
>This commit introduced the vid param to ndo_fdb_add and ndo_dflt_fdb_add
>which further call the dev_uc_add APIs... so it did introduced the
>ability to provide VID into these APIs, right? and we want to protect
>against anyone using this ability @ this point.

That is in-kernel change. Vs. usespace the patch is a no-op. If userspace
fills up NDA_VLAN, it is ignored before the patch as well as after. No
behaviour change, just +- cosmetics.

>
>> If was there already before when NDA_VLAN was set and ignored.
>> But other than this. I like the patch
>>
>> Reviewed-by: Jiri Pirko <jiri@resnulli.us>
