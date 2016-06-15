From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net] ixgbe: napi_poll must return the work done
Date: Wed, 15 Jun 2016 08:20:57 -0700
Message-ID: <CAKgT0UeU7tfo=i5O1j9ORwBJUVYGta5Z-NLw+xKGVLeHQ=PPtg@mail.gmail.com>
References: <37ccedd746ed932b9d73eff592f324f2a3fc6c6f.1465995724.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:35983 "EHLO
	mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753504AbcFOPU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 11:20:59 -0400
Received: by mail-it0-f45.google.com with SMTP id a5so110459233ita.1
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 08:20:58 -0700 (PDT)
In-Reply-To: <37ccedd746ed932b9d73eff592f324f2a3fc6c6f.1465995724.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 15, 2016 at 6:37 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> Currently the function ixgbe_poll() returns 0 when it clean completely
> the rx rings, but this foul budget accounting in core code.
> Fix this returning the actual work done, capped to weight - 1, since
> the core doesn't allow to return the full budget when the driver modifies
> the napi status
>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

I think the origin of reporting 0 was actually compatibility with some
NAPI code floating around from before the 2.6.24 kernel.

I'd be curious to know how much this is actually fouling things up.
Can you point to any specific issues it was causing?  If you end up
having to submit a v2 for any reason it might be useful if you can
provide the additional details on what actual issue it was causing.

You might also want to look at the other Intel drivers, specifically
ixgbevf and fm10k as I believe we have similar code in those drivers
as well.

Acked-by: Alexander Duyck <aduyck@mirantis.com>
