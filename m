From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH 8/8] fanotify: send events to userspace over socket
 reads
Date: Fri, 11 Sep 2009 10:15:45 -0400
Message-ID: <1252678545.2305.4.camel@dhcp231-106.rdu.redhat.com>
References: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com>
	 <20090911052649.32359.18553.stgit@paris.rdu.redhat.com>
	 <1252678130.30578.848.camel@desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	viro@zeniv.linux.org.uk, alan@linux.intel.com, hch@infradead.org
To: Daniel Walker <dwalker@fifo99.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1252678130.30578.848.camel@desktop>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2009-09-11 at 07:08 -0700, Daniel Walker wrote:
> On Fri, 2009-09-11 at 01:26 -0400, Eric Paris wrote:
> > fanotify sends event notification to userspace when userspace reads from the
> > fanotify socket. This patch implements the operations that happen at read
> > time.  These include opening the file descriptor to the original object and
> > then filling the userspace buffer.  The fd should be pollable to indicate when
> > it has data present and it should return how much data it has to send when the
> > FIONREAD ioctl is checked.
> > 
> 
> This patch has one checkpatch error, could you fix that? .. Also your
> whole series has several very long lines over 80 characters , you might
> want to consider trimming those down to 80 or less.. If you run these
> patches through checkpatch you should output like the following denoting
> the issues,
> 
> ERROR: "(foo*)" should be "(foo *)"
> #381: FILE: include/linux/fanotify.h:84:
> +                                  (struct fanotify_event_metadata*)(((char *)(meta)) + \

Yes I'll clean this up.  It was stolen straight from
include/linux/netlink.h NLMSG_NEXT with that exact spacing.

> WARNING: line over 80 characters
> #384: FILE: include/linux/fanotify.h:87:
> +#define FAN_EVENT_OK(meta, len)        ((long)(len) >= (long)FAN_EVENT_METADATA_LEN && \

I will look at all of the my 80+ character lines again.  This one in
particular, I will not break up.  I might read a little too broadly in
CodingStyle where it says the "exception to this is where exceeding 80
columns significantly increases readability and does not hide
information".

-Eric

