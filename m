From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] net: bridge: add helper to call
 /sbin/bridge-stp
Date: Thu, 8 Sep 2016 17:58:57 -0700
Message-ID: <20160908175857.35565496@xeon-e3>
References: <20160908165043.31042-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160908165043.31042-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu,  8 Sep 2016 12:50:43 -0400
Vivien Didelot <vivien.didelot@savoirfairelinux.com> wrote:

> If /sbin/bridge-stp is available on the system, bridge tries to execute
> it instead of the kernel implementation when starting/stopping STP.
> 
> If anything goes wrong with /sbin/bridge-stp, bridge silently falls back
> to kernel STP, making hard to debug userspace STP.
> 
> This patch adds a br_stp_call_user helper to start/stop userspace STP
> and debug errors from the program: abnormal exit status is stored in the
> lower byte and normal exit status is stored in higher byte.
> 
> Below is a simple example on a kernel with dynamic debug enabled:
> 
>     # ln -s /bin/false /sbin/bridge-stp
>     # brctl stp br0 on
>     br0: failed to start userspace STP (256)
>     # dmesg
>     br0: /sbin/bridge-stp exited with code 1
>     br0: failed to start userspace STP (256)
>     br0: using kernel STP
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

I understand that debugging STP is hard. But this solution looks like it
would break existing userspace because you changed an API.
