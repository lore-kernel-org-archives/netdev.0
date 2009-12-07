From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 11/31] Constify struct file_operations for 2.6.32 v1
Date: Mon, 7 Dec 2009 07:11:56 -0800
Message-ID: <20091207151156.GA27574@suse.de>
References: <4B198670.2000406@gmail.com> <4B198C43.50205@gmail.com> <4B19A333.5080103@gmail.com> <20091205000942.GA8224@suse.de> <4B19CA6F.4090700@gmail.com> <20091205041507.GA24885@suse.de> <4B1B0D40.3040209@gmail.com> <20091206172526.GA17480@suse.de> <4B1C500E.5040406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lenb@kernel.org, astarikovskiy@suse.de, mchehab@infradead.org,
	linville@tuxdriver.com, miklos@szeredi.hu, davem@davemloft.net,
	rostedt@goodmis.org, fweisbec@gmail.com, mingo@redhat.com,
	avi@redhat.com, mtosatti@redhat.com, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Emese Revfy <re.emese@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:40356 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935216AbZLGPPA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2009 10:15:00 -0500
Content-Disposition: inline
In-Reply-To: <4B1C500E.5040406@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 07, 2009 at 01:45:02AM +0100, Emese Revfy wrote:
> Greg KH wrote:
> > On Sun, Dec 06, 2009 at 02:47:44AM +0100, Emese Revfy wrote:
> >> Greg KH wrote:
> >>> On Sat, Dec 05, 2009 at 03:50:23AM +0100, Emese Revfy wrote:
> >>>> Greg KH wrote:
> >>>>> On Sat, Dec 05, 2009 at 01:02:59AM +0100, Emese Revfy wrote:
> >>>>>> -static struct file_operations ptmx_fops;
> >>>>>> +static const struct file_operations ptmx_fops = {
> >>>>>> +	.llseek		= no_llseek,
> >>>>>> +	.read		= tty_read,
> >>>>>> +	.write		= tty_write,
> >>>>>> +	.poll		= tty_poll,
> >>>>>> +	.unlocked_ioctl	= tty_ioctl,
> >>>>>> +	.compat_ioctl	= tty_compat_ioctl,
> >>>>>> +	.open		= ptmx_open,
> >>>>>> +	.release	= tty_release,
> >>>>>> +	.fasync		= tty_fasync,
> >>>>>> +};
> >>>>> You just made these functions all global, for no real good reason.  Why
> >>>>> did you do this?
> >>>> I think this is the only way to make ptmx_fops const, provided we want to. 
> >>> Why do we want to?
> >> Because I saw that checkpatch.pl itself tries to ensure the same I went
> >> through the whole tree looking for non-const file_operations structures
> >> and tried to make them const as best as I could. If you think making
> >> ptmx_fops const is not worth the effort I will remove it from the patch.
> > 
> > Based on the patch, I would think it is not worth it.
> > 
> > thanks,
> > 
> > greg k-h
> > 
> Ok, I removed the affected hunks.
> 
> From: Emese Revfy <re.emese@gmail.com>
> 
> Constify struct file_operations with some exceptions.

Now please break this patch (and your others) out into "one subsystem at
a time" type thing so it will have a chance at being applied.

thanks,

greg k-h
