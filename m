From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH v2 4/4] rhashtable-test: allow to retry even if -ENOMEM
 was returned
Date: Fri, 20 Nov 2015 18:28:41 +0100
Message-ID: <20151120172841.GD16648@orbit.nwl.cc>
References: <1448039840-11367-1-git-send-email-phil@nwl.cc>
 <1448039840-11367-5-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tgraf@suug.ch, fengguang.wu@intel.com, wfg@linux.intel.com,
	lkp@01.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1448039840-11367-5-git-send-email-phil@nwl.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 20, 2015 at 06:17:20PM +0100, Phil Sutter wrote:
> This is rather a hack to expose the current issue with rhashtable to
> under high pressure sometimes return -ENOMEM even though system memory
> is not exhausted and a consecutive insert may succeed.

Please note that this problem does not show every time when running the
test in default configuration on my system. With increased number of
threads though, it becomes very visible. Load test_rhashtable like so:

modprobe test_rhashtable enomem_retry=1 tcount=20

and grep dmesg for 'insertions retried after -ENOMEM'. In my case:

# dmesg | grep -E '(insertions retried after -ENOMEM|Started)' | tail
[   34.642980]  1 insertions retried after -ENOMEM
[   34.642989]  1 insertions retried after -ENOMEM
[   34.642994]  1 insertions retried after -ENOMEM
[   34.648353]  28294 insertions retried after -ENOMEM
[   34.689687]  31262 insertions retried after -ENOMEM
[   34.714015]  16280 insertions retried after -ENOMEM
[   34.736019]  15327 insertions retried after -ENOMEM
[   34.755100]  39012 insertions retried after -ENOMEM
[   34.769116]  49369 insertions retried after -ENOMEM
[   35.387200] Started 20 threads, 0 failed

Cheers, Phil
