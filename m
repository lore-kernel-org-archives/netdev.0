From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] (3/23) sk98: /proc interface related changes
Date: Fri, 12 Nov 2004 16:26:42 +0000
Message-ID: <20041112162641.GA7066@infradead.org>
References: <4192C60A.1050205@designassembly.de> <20041111154225.5cf85567@zqx3.pdx.osdl.net> <20041111155349.4537044c@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Michael Heyse <mhk@designassembly.de>,
        Mirko Lindner <mlindner@syskonnect.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20041111155349.4537044c@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Nov 11, 2004 at 03:53:49PM -0800, Stephen Hemminger wrote:
> The /proc intereface can be cleaned up a lot:
> + Pass the device to through the proc data/seq_private hook.
> + No longer needs to have a list of network devices 
> + use seq_printf directly rather than indirection into a buffer
> + failure to create proc directory or interface should not
>   be fatal.
> + if PROC_FS not configured, let the stubs cause the necessary
>   code elimination rather than using #ifdef

This is still totally broken because dev->name may change between
registration and removal.  If a netdriver wants to use procfs file
per-adapter it needs to use an enumeration scheme independant of the
netdevice naming.  Or even better stop using procfs at all.
