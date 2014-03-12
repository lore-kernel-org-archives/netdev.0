From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH 2/2] net: Implement SO_PEERCGROUP
Date: Wed, 12 Mar 2014 14:00:28 -0700
Message-ID: <5320CAEC.6030008@amacapital.net>
References: <1394657163-7472-1-git-send-email-vgoyal@redhat.com> <1394657163-7472-3-git-send-email-vgoyal@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394657163-7472-3-git-send-email-vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/12/2014 01:46 PM, Vivek Goyal wrote:
> Implement SO_PEERCGROUP along the lines of SO_PEERCRED. This returns the
> cgroup of first mounted hierarchy of the task. For the case of client,
> it represents the cgroup of client at the time of opening the connection.
> After that client cgroup might change.

Even if people decide that sending cgroups over a unix socket is a good
idea, this API has my NAK in the strongest possible sense, for whatever
my NAK is worth.

IMO SO_PEERCRED is a disaster.  Calling send(2) or write(2) should
*never* imply the use of a credential.  A program should always have to
*explicitly* request use of a credential.  What you want is SCM_CGROUP.

(I've found privilege escalations before based on this observation, and
I suspect I'll find them again.)


Note that I think that you really want SCM_SOMETHING_ELSE and not
SCM_CGROUP, but I don't know what the use case is yet.

--Andy
