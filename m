From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: hung task in mac80211
Date: Wed, 06 Sep 2017 15:30:10 +0200
Message-ID: <1504704610.23905.1.camel@sipsolutions.net>
References: <CAGnkfhwi9MmtLneeU23iWEGLj9cb1ODb3KzzOqTDvA6nNVsugg@mail.gmail.com>
         <20170906144019.1c98a636@elisabeth>
         <1504702115.13457.16.camel@sipsolutions.net>
         <20170906151922.4a320b1d@elisabeth>
         <1504704060.13457.20.camel@sipsolutions.net>
         <20170906152709.673f230d@elisabeth>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Matteo Croce <mcroce@redhat.com>, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stefano Brivio <sbrivio@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170906152709.673f230d@elisabeth>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-09-06 at 15:27 +0200, Stefano Brivio wrote:
> 
> Yes, that was based on the assumption that the initial part of
> __ieee80211_start_rx_ba_session() can't really affect the AMPDU
> state-machine in any way.

That's not really the point, if that changes that function would have
to move the locking around, and nothing else.

The point is more that code in ieee80211_ba_session_work() could assume
the lock is held across the entire loop, since that's the way it's
written and looks like even with your patch.

So for example replacing the loop of tid = 0..NUM_TIDS-1 with a
list_for_each_entry() would already be unsafe with the dropping if the
list were to require the mutex for locking.

johannes
