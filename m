From: David Decotigny <david.decotigny@google.com>
Subject: Re: [PATCH net-next v5 07/10] forcedeth: implement ndo_get_stats64() API
Date: Wed, 16 Nov 2011 11:25:23 -0800
Message-ID: <CAG88wWa7UsPSfX_NdNDkQeuWN0LYYDVckShgDj9GvMq2mtrpbQ@mail.gmail.com>
References: <cover.1321420513.git.david.decotigny@google.com>
 <dcc1ec263220b7bb1f7271933c30a8f89c19d991.1321420513.git.david.decotigny@google.com>
 <20111116085533.0982001e@s6510.linuxnetplumber.net> <1321463694.2709.1.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Ian Campbell <ian.campbell@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Szymon Janc <szymon@janc.net.pl>,
	Richard Jones <rick.jones2@hp.com>,
	Ayaz Abdulla <AAbdulla@nvidia.com>
To: Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:63026 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751765Ab1KPTZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 14:25:45 -0500
Received: by iage36 with SMTP id e36so1033032iag.19
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 11:25:44 -0800 (PST)
In-Reply-To: <1321463694.2709.1.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for your feedback on these concerns.

On Wed, Nov 16, 2011 at 9:14 AM, Ben Hutchings
<bhutchings@solarflare.com> wrote:
> On Wed, 2011-11-16 at 08:55 -0800, Stephen Hemminger wrote:
>> Or realize that the Tx side is single threaded by dev->xmit_lock already
>> and the Rx side is single threaded by NAPI.
>
> Right.

Yes, that's what I meant by "Each software stat field is updated by
one single writer." in a previous email. However, I think that TX and
RX paths are not always synchronized. So I'm afraid that if I'm using
a single seqcount, I might run into trouble in the absence of a lock
around each update.... and I'd really prefer to avoid such a lock. Are
you suggesting I should use 2 independent seqcounts? One for RX path,
the other for TX path, all this without a lock around writers?

Side-note: what are the bad implications of using atomic_t (in the fast paths)?
