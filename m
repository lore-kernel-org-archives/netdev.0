From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Pure polling mode for netdevices
Date: Fri, 21 Oct 2016 11:41:46 -0700
Message-ID: <1477075306.7065.86.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20161021180316.GA305@zach-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Zach Brown <zach.brown@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161021180316.GA305@zach-desktop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-10-21 at 13:03 -0500, Zach Brown wrote:
> Is there a way to get NAPI to poll all the time?
> Or just any way to get netdevices to use only polling and no interrupts?
> 
> We have some rt targets where the jitter can be improved by disabling
> interrupts and using just polling. In these cases we're okay with the
> performance downsides that come with polling.
> 
> In particular we already have an implementation for the cadence macb driver
> that does only polling mode and have verified that it improves the
> jitter.
> 
> We're hoping for a more general existing solution or at the very least a
> solution that would be accepted upstream. Any thoughts?

This is not yet done, although you could use busy poll infrastructure to
get this without a kernel change.

Open as many TCP flows are necessary to traverse all the queues you care
about, then loop on recvmsg() to trigger NAPI polling.
