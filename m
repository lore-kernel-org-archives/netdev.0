From: Mark Greer <mgreer@animalcreek.com>
Subject: Re: [PATCH 3/3] nfc: trf7970a: Prevent repeated polling from
 crashing the kernel
Date: Tue, 20 Dec 2016 11:59:05 -0700
Message-ID: <20161220185905.GA5867@animalcreek.com>
References: <1482250592-4268-1-git-send-email-glansberry@gmail.com>
 <1482250592-4268-3-git-send-email-glansberry@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, lauro.venancio@openbossa.org,
        aloisio.almeida@openbossa.org, sameo@linux.intel.com,
        robh+dt@kernel.org, mark.rutland@arm.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        justin@kuvee.com, Jaret Cantu <jaret.cantu@timesys.com>
To: Geoff Lansberry <geoff@kuvee.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1482250592-4268-3-git-send-email-glansberry@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 20, 2016 at 11:16:32AM -0500, Geoff Lansberry wrote:
> From: Jaret Cantu <jaret.cantu@timesys.com>
> 
> Repeated polling attempts cause a NULL dereference error to occur.
> This is because the state of the trf7970a is currently reading but
> another request has been made to send a command before it has finished.

How is this happening?  Was trf7970a_abort_cmd() called and it didn't
work right?  Was it not called at all and there is a bug in the digital
layer?  More details please.

> The solution is to properly kill the waiting reading (workqueue)
> before failing on the send.

If the bug is in the calling code, then that is what should get fixed.
This seems to be a hack to work-around a digital layer bug.

Mark
--
