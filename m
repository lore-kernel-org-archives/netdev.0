From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/3] printk: implement support for extended console
 drivers
Date: Thu, 30 Apr 2015 14:31:28 -0700
Message-ID: <20150430143128.68c2295ca18f1b872876f129@linux-foundation.org>
References: <1430318704-32374-1-git-send-email-tj@kernel.org>
	<1430318704-32374-4-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pmladek@suse.cz, davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Kay Sievers <kay@vrfy.org>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430318704-32374-4-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 29 Apr 2015 10:45:04 -0400 Tejun Heo <tj@kernel.org> wrote:

> printk log_buf keeps various metadata for each message including its
> sequence number and timestamp.  The metadata is currently available
> only through /dev/kmsg and stripped out before passed onto console
> drivers.  We want this metadata to be available to console drivers too
> so that console consumers can get full information including the
> metadata and dictionary, which among other things can be used to
> detect whether messages got lost in transit.
> 
> This patch implements support for extended console drivers.  Consoles
> can indicate that they want extended messages by setting the new
> CON_EXTENDED flag and they'll be fed messages formatted the same way
> as /dev/kmsg.
> 
>  "<level>,<sequnum>,<timestamp>,<contflag>;<message text>\n"
> 
> If extended consoles exist, in-kernel fragment assembly is disabled.
> This ensures that all messages emitted to consoles have full metadata
> including sequence number.  The contflag carries enough information to
> reassemble the fragments from the reader side trivially.  Note that
> this only affects /dev/kmsg.  Regular console and /proc/kmsg outputs
> are not affected by this change.
> 
> * Extended message formatting for console drivers is enabled iff there
>   are registered extended consoles.
> 
> * Comment describing /dev/kmsg message format updated to add missing
>   contflag field and help distinguishing variable from verbatim terms.

So if I'm understanding this correctly, the /dev/kmsg output is altered
(different cont handling) if some console registers with CON_EXTENDED
(and there are no such consoles yet, so the patch is a no-op).

If correct, this seems undesirable - registration of a CON_EXTENDED
console collaterally damages the /dev/kmsg interface?  If the user has
an app which depends on the original /dev/kmsg format then they'll be
wondered what-the-heck-just-happened?
