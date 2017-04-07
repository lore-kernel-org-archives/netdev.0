From: Ville =?iso-8859-1?Q?Syrj=E4l=E4?= <ville.syrjala@linux.intel.com>
Subject: [regression v4.11] 617f01211baf ("8139too: use napi_complete_done()")
Date: Fri, 7 Apr 2017 21:17:54 +0300
Message-ID: <20170407181754.GL30290@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

My old P3 laptop started to die on me in the middle of larger compile
jobs (using distcc) after v4.11-rc<something>. I bisected the problem
to 617f01211baf ("8139too: use napi_complete_done()").

Unfortunately I wasn't able to capture a full oops as the machine doesn't
have serial and ramoops failed me. I did get one partial oops on vgacon
which showed rtl8139_poll() being involved (EIP was around
_raw_spin_unlock_irqrestore() supposedly), so seems to agree with my
bisect result.

So maybe some kind of nasty thing going between the hard irq and
softirq? Perhaps UP related? I tried to stare at the locking around
rtl8139_poll() for a while but it looked mostly sane to me.

-- 
Ville Syrjälä
Intel OTC
