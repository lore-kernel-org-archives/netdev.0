From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing
 cgroup path
Date: Thu, 24 Apr 2014 16:48:20 -0400 (EDT)
Message-ID: <20140424.164820.1543648508330465096.davem@davemloft.net>
References: <20140423164537.GD24651@redhat.com>
	<20140423.132955.671992126955940387.davem@davemloft.net>
	<20140424203427.GC19091@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, dwalsh-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140424203427.GC19091-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Thu, 24 Apr 2014 16:34:27 -0400

> By open() time you mean at socket() time or at connect() time?

I mean at all of the places at which init_peercred() occurs.

> You also mentioned that you want SO_PEERCGROUP and SO_PASSCGROUP as
> pairs like SO_PEERCRED and SO_PASSCRED.  But to me, SO_PEERCRED and
> SO_PASSCRED are not *exact* pairs and are little different in their
> semantics.  SO_PEERCRED gives us client creds at connect() time
> while SO_PASSCRED client's real creds at sendmsg() time. SO_PASSCRED
> does not store client's credential's at connect() time for datagram
> sockets.

Then you haven't been following the discussion.

The client's credentials at sendmsg()/write() time are "DO NOT CARE".

You cannot even guarentee the semantics in the logging example if
you ask for these "client identity at sendmsg() time" semantics.

What if the event occured when the client was in cgroup1, and the
log message goes out after it has been moved into cgroup2?

That is just proof that this whole idea is fundamentally flawed.

You guys need to come up with something else to achieve your goals,
this isn't it.
