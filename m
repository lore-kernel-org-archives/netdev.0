From: Eric Dumazet <edumazet@google.com>
Subject: Re: [net-next PATCH 2/2] tcp: Record Rx hash and NAPI ID in tcp_child_process
Date: Mon, 20 Mar 2017 15:06:03 -0700
Message-ID: <CANn89i+tA5fpzwr=Dm9UgdgN5wP2iPsvNKYkJjzz2V09-uatkA@mail.gmail.com>
References: <20170320214643.13922.51284.stgit@localhost.localdomain> <20170320214854.13922.5086.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, sridhar.samudrala@intel.com,
        David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170320214854.13922.5086.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 20, 2017 at 2:48 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
>
> While working on some recent busy poll changes we found that child sockets
> were being instantiated without NAPI ID being set.  In our first attempt to
> fix it, it was suggested that we should just pull programming the NAPI ID
> into the function itself since all callers will need to have it set.
>
> In addition to NAPI ID I have decided to also pull in populating the Rx
> hash since it likely has the same problem as NAPI ID but just doesn't have
> the visibility.

It looks like Rx hash was initialized elsewhere (
tcp_get_cookie_sock() & tcp_check_req())

So this probably could be cleaned up, if done at the proper place ;)
